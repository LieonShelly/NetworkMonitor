//
//  MetalLineThickener.swift
//  LTApp
//
//  Created by Renjun Li on 2025/12/3.
//


import UIKit
import MetalKit

class MetalLineThickener {
    nonisolated(unsafe) static let shared = MetalLineThickener()
    
    private let device: MTLDevice?
    private let commandQueue: MTLCommandQueue?
    private let pipelineState: MTLComputePipelineState?
    private let textureLoader: MTKTextureLoader?
    
    private init() {
        self.device = MTLCreateSystemDefaultDevice()
        self.commandQueue = device?.makeCommandQueue()
        self.textureLoader = device.map { MTKTextureLoader(device: $0) }
        
        // 加载 Shader
        guard let device = device,
              let library = device.makeDefaultLibrary(),
              let function = library.makeFunction(name: "thickenBlackLines") else {
            self.pipelineState = nil
            print("Error: Could not load Metal shader 'thickenBlackLines'")
            return
        }
        self.pipelineState = try? device.makeComputePipelineState(function: function)
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
        
        // 2. 手动计算需要多少个组(Grid Size)才能覆盖整张图
        // 公式：(图片尺寸 + 组尺寸 - 1) / 组尺寸 -> 实现向上取整
        // 例如：图片宽100，组宽32。 (100+31)/32 = 4组。 4*32=128，足够覆盖100。
        let threadgroupsPerGrid = MTLSizeMake(
            (inputTexture.width + w - 1) / w,
            (inputTexture.height + h - 1) / h,
            1)
        
        // 3. 使用兼容性最好的 dispatchThreadgroups API
        computeEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
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
