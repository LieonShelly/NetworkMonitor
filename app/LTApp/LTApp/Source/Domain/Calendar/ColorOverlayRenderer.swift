//
//  OverlayColor.swift
//  LTApp
//
//  Created by Renjun Li on 2026/4/8.
//


import UIKit
import MetalKit

// 与 Metal Shader 中保持一致的结构体
private struct OverlayColor {
    var color: SIMD4<Float>
}

@Observable
public class ColorOverlayRenderer: @unchecked Sendable {
    
    // 满足验收标准 3: 复用现有的单例或实例
    public static let shared = ColorOverlayRenderer()
    
    private var device: MTLDevice?
    private var commandQueue: MTLCommandQueue?
    private var pipelineState: MTLComputePipelineState?
    
    public init() {
        self.device = MTLCreateSystemDefaultDevice()
        self.commandQueue = device?.makeCommandQueue()
        
        // 编译加载我们在需求 1 中写的 Shader
        if let device = device,
           let library = device.makeDefaultLibrary(),
           let function = library.makeFunction(name: "apply_color_overlay") {
            do {
                self.pipelineState = try device.makeComputePipelineState(function: function)
            } catch {
                print("Metal Pipeline Error: \(error)")
            }
        }
    }
    
    /// 需求 2 核心方法：基于 UIImage 的同步渲染
    public func applyOverlay(to image: UIImage, color: UIColor) -> UIImage? {
        // 验收标准 4：设备不可用或编译失败返回 nil
        guard let device = device,
              let commandQueue = commandQueue,
              let pipelineState = pipelineState,
              let cgImage = image.cgImage else {
            return nil
        }
        
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let totalBytes = height * bytesPerRow
        
        // 1. 提取原始图像的 RGBA 像素数据 (用于生成 Mask 和创建输入纹理)
        var rawData = [UInt8](repeating: 0, count: totalBytes)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: &rawData,
                                      width: width, height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        // 将 UIImage 绘制到内存上下文中获取像素
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        // 2. 调用需求 1 的 C/Swift 桥接函数生成 Mask 掩码
        let maskTotalPixels = width * height
        var maskData = [UInt8](repeating: 0, count: maskTotalPixels)
        generate_solid_mask(imageData: rawData, width: Int32(width), height: Int32(height), maskData: &maskData)
        
        // 3. 创建并填充 Metal 纹理
        let textureDesc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: width, height: height, mipmapped: false)
        textureDesc.usage = [.shaderRead, .shaderWrite]
        textureDesc.storageMode = .shared
        
        guard let inTexture = device.makeTexture(descriptor: textureDesc) else { return nil }
        inTexture.replace(region: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0, withBytes: rawData, bytesPerRow: bytesPerRow)
        
        let maskDesc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .r8Unorm, width: width, height: height, mipmapped: false)
        maskDesc.usage = [.shaderRead]
        maskDesc.storageMode = .shared
        guard let maskTexture = device.makeTexture(descriptor: maskDesc) else { return nil }
        maskTexture.replace(region: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0, withBytes: maskData, bytesPerRow: width) // 单通道
        
        guard let outTexture = device.makeTexture(descriptor: textureDesc) else { return nil }
        
        // 4. 配置 Command Buffer 并执行 Compute Shader
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeComputeCommandEncoder() else { return nil }
        
        encoder.setComputePipelineState(pipelineState)
        encoder.setTexture(inTexture, index: 0)
        encoder.setTexture(maskTexture, index: 1)
        encoder.setTexture(outTexture, index: 2)
        
        // 处理颜色参数
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        var overlayColor = OverlayColor(color: SIMD4<Float>(Float(r), Float(g), Float(b), Float(a)))
        encoder.setBytes(&overlayColor, length: MemoryLayout<OverlayColor>.stride, index: 0)
        
        // 计算并分配线程 (iOS 11+ 支持自动边界处理的 dispatchThreads)
        let w = pipelineState.threadExecutionWidth
        let h = pipelineState.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSizeMake(w, h, 1)
        let threadgroupsPerGrid = MTLSizeMake((width + w - 1) / w, (height + h - 1) / h, 1)
        encoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        
        encoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted() // 同步等待渲染完成
        
        // 5. 将输出纹理读回 CPU 内存并转为 UIImage
        var outRawData = [UInt8](repeating: 0, count: totalBytes)
        outTexture.getBytes(&outRawData, bytesPerRow: bytesPerRow, from: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0)
        
        guard let outContext = CGContext(data: &outRawData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
              let outCGImage = outContext.makeImage() else { return nil }
        
        // 验收标准 5：保留原始图像的 scale 和 orientation
        return UIImage(cgImage: outCGImage, scale: image.scale, orientation: image.imageOrientation)
    }
}
