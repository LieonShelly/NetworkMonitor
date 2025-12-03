//
//  MetalImageProcessor.swift
//  LTApp
//
//  Created by Renjun Li on 2025/12/3.
//


@preconcurrency import UIKit
import MetalKit

class MetalImageProcessor: @unchecked Sendable {
    // 单例
    static let shared = MetalImageProcessor()
    
    private let device: MTLDevice?
    private let commandQueue: MTLCommandQueue?
    private let textureLoader: MTKTextureLoader?
    
    // 两个 Pipeline State
    private let cropPipelineState: MTLComputePipelineState?
    private let thickenPipelineState: MTLComputePipelineState?
    
    private init() {
        self.device = MTLCreateSystemDefaultDevice()
        self.commandQueue = device?.makeCommandQueue()
        self.textureLoader = device.map { MTKTextureLoader(device: $0) }
        
        guard let device = device, let library = device.makeDefaultLibrary() else {
            self.cropPipelineState = nil
            self.thickenPipelineState = nil
            return
        }
        
        // 加载裁剪 Shader
        if let cropFunc = library.makeFunction(name: "detectContentBounds") {
            self.cropPipelineState = try? device.makeComputePipelineState(function: cropFunc)
        } else { self.cropPipelineState = nil }
        
        // 加载加粗 Shader
        if let thickenFunc = library.makeFunction(name: "thickenBlackLines") {
            self.thickenPipelineState = try? device.makeComputePipelineState(function: thickenFunc)
        } else { self.thickenPipelineState = nil }
    }
    
    // 对应 Shader 的结构体
    struct BoundingBoxResult {
        var minX: UInt32
        var minY: UInt32
        var maxX: UInt32
        var maxY: UInt32
    }
    
    /// 执行完整流程：裁剪 -> 加粗
    /// - Parameters:
    ///   - image: 原始图片
    ///   - thickness: 加粗力度 (1 or 2)
    func process(_ image: UIImage, thickness: Int = 1, completion: ((UIImage?) -> Void)? = nil) {
        guard let device = device,
              let commandQueue = commandQueue,
              let cropPipelineState = cropPipelineState,
              let thickenPipelineState = thickenPipelineState,
              let textureLoader = textureLoader,
              let cgImage = image.cgImage else {
            completion?(nil)
            return
        }
        
        // 1. 加载原图纹理
        let options: [MTKTextureLoader.Option: Any] = [.SRGB: false, .origin: MTKTextureLoader.Origin.topLeft]
        guard let originalTexture = try? textureLoader.newTexture(cgImage: cgImage, options: options) else {
            completion?(nil)
            return
        }
        
        // --- 阶段一：计算裁剪边界 ---
        
        // 初始化 Buffer (反向初始化 min/max 以便 atomic 更新)
        var initData = BoundingBoxResult(minX: UInt32(originalTexture.width),
                                         minY: UInt32(originalTexture.height),
                                         maxX: 0, maxY: 0)
        guard let buffer = device.makeBuffer(bytes: &initData,
                                             length: MemoryLayout<BoundingBoxResult>.stride,
                                             options: .storageModeShared) else {
            completion?(nil)
            return
        }
        
        guard let commandBuffer1 = commandQueue.makeCommandBuffer(),
              let encoder1 = commandBuffer1.makeComputeCommandEncoder() else {
            completion?(nil)
            return
        }
        
        encoder1.setComputePipelineState(cropPipelineState)
        encoder1.setTexture(originalTexture, index: 0)
        encoder1.setBuffer(buffer, offset: 0, index: 0)
        
        // 模拟器兼容性调度 (detectContentBounds)
        dispatchCompatible(encoder: encoder1, pipeline: cropPipelineState, width: originalTexture.width, height: originalTexture.height)
        
        encoder1.endEncoding()
        
        // 提交第一个命令缓冲区，并在完成后读取结果
        commandBuffer1.addCompletedHandler { _ in
            let ptr = buffer.contents().bindMemory(to: BoundingBoxResult.self, capacity: 1)
            let result = ptr.pointee
            
            // 检查是否全是空白
            if result.maxX < result.minX || result.maxY < result.minY {
                // 内容为空，直接返回原图或 nil
                completion?(image)
                return
            }
            
            // 计算裁切区域
            let cropRect = MTLRegionMake2D(Int(result.minX), Int(result.minY),
                                           Int(result.maxX - result.minX + 1),
                                           Int(result.maxY - result.minY + 1))
            
            // --- 阶段二：使用 Texture View 和 加粗 Shader ---
            
            self.runThickenPass(device: device,
                                commandQueue: commandQueue,
                                pipeline: thickenPipelineState,
                                originalTexture: originalTexture,
                                cropRegion: cropRect,
                                thickness: thickness,
                                originalScale: image.scale,
                                orientation: image.imageOrientation,
                                completion: completion)
        }
        
        commandBuffer1.commit()
    }
    
    nonisolated private func runThickenPass(device: MTLDevice,
                                    commandQueue: MTLCommandQueue,
                                    pipeline: MTLComputePipelineState,
                                    originalTexture: MTLTexture, // 直接传原图
                                    cropRegion: MTLRegion,       // 裁剪区域数据
                                    thickness: Int,
                                    originalScale: CGFloat,
                                    orientation: UIImage.Orientation,
                                            completion: ((UIImage?) -> Void)?) {
            
            // 1. 创建输出纹理 (尺寸 = 裁剪后的大小)
            // 这是一个全新的、紧凑的小纹理
            let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: originalTexture.pixelFormat,
                                                                      width: cropRegion.size.width,
                                                                      height: cropRegion.size.height,
                                                                      mipmapped: false)
            descriptor.usage = [.shaderRead, .shaderWrite]
            
            guard let outputTexture = device.makeTexture(descriptor: descriptor) else {
                completion?(nil)
                return
            }
            
            guard let commandBuffer2 = commandQueue.makeCommandBuffer(),
                  let encoder2 = commandBuffer2.makeComputeCommandEncoder() else {
                completion?(nil)
                return
            }
            
            encoder2.setComputePipelineState(pipeline)
            
            // 输入：原始大图
            encoder2.setTexture(originalTexture, index: 0)
            // 输出：裁剪后的小图
            encoder2.setTexture(outputTexture, index: 1)
            
            // 参数 0: 半径
            var radius = Int32(thickness)
            encoder2.setBytes(&radius, length: MemoryLayout<Int32>.size, index: 0)
            
            // 参数 1: 【新增】裁剪偏移量 (minX, minY)
            // Shader 会用这个偏移量去原图里找数据
            var offset = SIMD2<UInt32>(UInt32(cropRegion.origin.x), UInt32(cropRegion.origin.y))
            encoder2.setBytes(&offset, length: MemoryLayout<SIMD2<UInt32>>.size, index: 1)
            
            // 调度：注意这里是用 outputTexture (小图) 的尺寸来计算线程组
            // 因为我们的目的是填满这张小图
            dispatchCompatible(encoder: encoder2, pipeline: pipeline, width: outputTexture.width, height: outputTexture.height)
            
            encoder2.endEncoding()

            commandBuffer2.addCompletedHandler { _ in
                let resultImage = self.textureToImage(texture: outputTexture, scale: originalScale, orientation: orientation)
                completion?(resultImage)
            }
            
            commandBuffer2.commit()
        }
    
    
    private func dispatchCompatible(encoder: MTLComputeCommandEncoder, pipeline: MTLComputePipelineState, width: Int, height: Int) {
        let w = pipeline.threadExecutionWidth
        let h = pipeline.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSizeMake(w, h, 1)
        
        let threadgroupsPerGrid = MTLSizeMake(
            (width + w - 1) / w,
            (height + h - 1) / h,
            1)
        
        encoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
    }
    
    private func textureToImage(texture: MTLTexture, scale: CGFloat, orientation: UIImage.Orientation) -> UIImage? {
        let width = texture.width
        let height = texture.height
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        var data = [UInt8](repeating: 0, count: Int(bytesPerRow * height))
        
        let region = MTLRegionMake2D(0, 0, width, height)
        texture.getBytes(&data, bytesPerRow: bytesPerRow, from: region, mipmapLevel: 0)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        // 使用 premultipliedLast 以兼容 Metal 的默认输出
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let context = CGContext(data: &data,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo.rawValue),
              let cgImage = context.makeImage() else {
            return nil
        }
        
        return UIImage(cgImage: cgImage, scale: scale, orientation: orientation)
    }
}
