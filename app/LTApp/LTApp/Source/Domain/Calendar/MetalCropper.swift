//
//  MetalCropper.swift
//  LTApp
//
//  Created by Renjun Li on 2025/12/3.
//

@preconcurrency import UIKit
import MetalKit

class MetalCropper {
    // 单例模式，避免重复创建 Device 和 Pipeline
    nonisolated(unsafe) static let shared = MetalCropper()
    
    private let device: MTLDevice?
    private let commandQueue: MTLCommandQueue?
    private let pipelineState: MTLComputePipelineState?
    private let textureLoader: MTKTextureLoader?
    
    private init() {
        self.device = MTLCreateSystemDefaultDevice()
        self.commandQueue = device?.makeCommandQueue()
        self.textureLoader = device.map { MTKTextureLoader(device: $0) }
        
        guard let device = device,
              let library = device.makeDefaultLibrary(),
              let function = library.makeFunction(name: "detectContentBounds") else {
            self.pipelineState = nil
            return
        }
        self.pipelineState = try? device.makeComputePipelineState(function: function)
    }
    
    struct BoundingBoxResult {
        var minX: UInt32
        var minY: UInt32
        var maxX: UInt32
        var maxY: UInt32
    }
    
    func cropImage(_ image: UIImage, completion: @escaping (UIImage?) -> Void) {
        guard let device = device,
              let commandQueue = commandQueue,
              let pipelineState = pipelineState,
              let textureLoader = textureLoader,
              let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        // 1. 将 UIImage 转换为 Metal Texture
        let options: [MTKTextureLoader.Option: Any] = [.SRGB: false, .origin: MTKTextureLoader.Origin.topLeft]
        guard let texture = try? textureLoader.newTexture(cgImage: cgImage, options: options) else {
            completion(nil)
            return
        }
        
        // 2. 准备结果 Buffer
        var initData = BoundingBoxResult(minX: UInt32(texture.width),
                                         minY: UInt32(texture.height),
                                         maxX: 0,
                                         maxY: 0)
        
        guard let buffer = device.makeBuffer(bytes: &initData,
                                             length: MemoryLayout<BoundingBoxResult>.stride,
                                             options: .storageModeShared) else {
            completion(nil)
            return
        }
        
        // 3. 创建指令缓冲区
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let computeEncoder = commandBuffer.makeComputeCommandEncoder() else {
            completion(nil)
            return
        }
        
        computeEncoder.setComputePipelineState(pipelineState)
        computeEncoder.setTexture(texture, index: 0)
        computeEncoder.setBuffer(buffer, offset: 0, index: 0)
        
        // 4. 计算线程组大小
        let w = pipelineState.threadExecutionWidth
        let h = pipelineState.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSizeMake(w, h, 1)
        let threadsPerGrid = MTLSizeMake(texture.width, texture.height, 1)
        
        // --- 4. 修复核心：计算线程组大小 (兼容模拟器和所有真机) ---
        // 设定每个线程组的大小 (通常 8x8, 16x16 或 32x8 等，取决于 GPU)
        // 这里为了安全和通用，我们计算一个合适的矩形
        
        // 手动计算需要多少个组才能覆盖整张图 (向上取整)
        // 比如：图片宽 100，组宽 32 -> 需要 4 个组 (32*4 = 128 > 100)
        let threadgroupsPerGrid = MTLSizeMake(
            (texture.width + w - 1) / w,
            (texture.height + h - 1) / h,
            1)
        
        // 【关键修改】使用 dispatchThreadgroups 而不是 dispatchThreads
        computeEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        
        computeEncoder.endEncoding()
        
        commandBuffer.addCompletedHandler { _ in
            let ptr = buffer.contents().bindMemory(to: BoundingBoxResult.self, capacity: 1)
            let result = ptr.pointee
            
            if result.maxX < result.minX || result.maxY < result.minY {
                DispatchQueue.main.async { completion(image) }
                return
            }
            
            let rect = CGRect(x: Int(result.minX),
                              y: Int(result.minY),
                              width: Int(result.maxX - result.minX + 1),
                              height: Int(result.maxY - result.minY + 1))
            
            if let croppedCG = cgImage.cropping(to: rect) {
                let processed = UIImage(cgImage: croppedCG, scale: image.scale, orientation: image.imageOrientation)
                DispatchQueue.main.async { completion(processed) }
            } else {
                DispatchQueue.main.async { completion(nil) }
            }
        }
        
        commandBuffer.commit()
    }
    
    
    /// 加粗图片中的黑色线条
    /// - Parameters:
    ///   - image: 输入图片
    ///   - thickness: 加粗力度 (1: 轻微, 2: 中等, 3: 极粗)
    func thicken(_ image: UIImage, thickness: Int = 1, completion: @escaping (UIImage?) -> Void) {
        guard let device = device,
              let commandQueue = commandQueue,
              let pipelineState = pipelineState,
              let textureLoader = textureLoader,
              let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        // 1. 创建输入纹理 (Input Texture)
        let options: [MTKTextureLoader.Option: Any] = [.SRGB: false, .origin: MTKTextureLoader.Origin.topLeft]
        guard let inputTexture = try? textureLoader.newTexture(cgImage: cgImage, options: options) else {
            completion(nil)
            return
        }
        
        // 2. 创建输出纹理 (Output Texture) - 必须是可写的
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: inputTexture.pixelFormat,
                                                                width: inputTexture.width,
                                                                height: inputTexture.height,
                                                                mipmapped: false)
        descriptor.usage = [.shaderRead, .shaderWrite] // 关键：允许写入
        guard let outputTexture = device.makeTexture(descriptor: descriptor) else {
            completion(nil)
            return
        }
        
        // 3. 编码指令
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let computeEncoder = commandBuffer.makeComputeCommandEncoder() else {
            completion(nil)
            return
        }
        
        computeEncoder.setComputePipelineState(pipelineState)
        computeEncoder.setTexture(inputTexture, index: 0)
        computeEncoder.setTexture(outputTexture, index: 1)
        
        // 传入加粗参数
        var radius = Int32(thickness)
        computeEncoder.setBytes(&radius, length: MemoryLayout<Int32>.size, index: 0)
        
        // 线程组计算
        let w = pipelineState.threadExecutionWidth
        let h = pipelineState.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSizeMake(w, h, 1)
        let threadsPerGrid = MTLSizeMake(inputTexture.width, inputTexture.height, 1)
        
        computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        computeEncoder.endEncoding()
        
        // 4. 获取结果
        commandBuffer.addCompletedHandler { _ in
            // 将 Output Texture 转回 UIImage
            let outImage = self.textureToImage(texture: outputTexture, scale: image.scale, orientation: image.imageOrientation)
            DispatchQueue.main.async {
                completion(outImage)
            }
        }
        
        commandBuffer.commit()
    }
    
    // 辅助：纹理转 UIImage
    private func textureToImage(texture: MTLTexture, scale: CGFloat, orientation: UIImage.Orientation) -> UIImage? {
        let width = texture.width
        let height = texture.height
        let bytesPerPixel = 4 // RGBA8888
        let bytesPerRow = width * bytesPerPixel
        var data = [UInt8](repeating: 0, count: Int(bytesPerRow * height))
        
        let region = MTLRegionMake2D(0, 0, width, height)
        texture.getBytes(&data, bytesPerRow: bytesPerRow, from: region, mipmapLevel: 0)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
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
