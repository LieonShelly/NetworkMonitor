import UIKit
import MetalKit

// 与 Metal Shader 中严格保持一致的结构体 (16 字节)
private struct OverlayColor {
    var color: SIMD4<Float>
}

@Observable
public class ColorOverlayRenderer: @unchecked Sendable {
    
    public static let shared = ColorOverlayRenderer()
    
    private var device: MTLDevice?
    private var commandQueue: MTLCommandQueue?
    
    // 我们现在需要两个管线状态 (双 Pass)
    private var dilatePipelineState: MTLComputePipelineState?
    private var applyOverlayPipelineState: MTLComputePipelineState?
    
    public init() {
        self.device = MTLCreateSystemDefaultDevice()
        self.commandQueue = device?.makeCommandQueue()
        
        if let device = device,
           let library = device.makeDefaultLibrary() {
            do {
                // 编译 Pass 1: 膨胀着色器
                if let dilateFunc = library.makeFunction(name: "dilate_mask") {
                    self.dilatePipelineState = try device.makeComputePipelineState(function: dilateFunc)
                }
                // 编译 Pass 2: 上色着色器
                if let overlayFunc = library.makeFunction(name: "apply_color_overlay") {
                    self.applyOverlayPipelineState = try device.makeComputePipelineState(function: overlayFunc)
                }
            } catch {
                print("Metal Pipeline 初始化失败: \(error)")
            }
        }
    }
    
    /// 需求 2 核心方法：基于 UIImage 的同步渲染
    /// - Parameters:
    ///   - image: 原始图像
    ///   - color: 目标叠加颜色
    ///   - expandRadius: 蒙版向外膨胀的像素半径 (0 表示不膨胀)
    public func applyOverlay(to image: UIImage, color: UIColor, expandRadius: Int32 = 30) -> UIImage? {
        
        guard let device = device,
              let commandQueue = commandQueue,
              let dilatePipelineState = dilatePipelineState,
              let applyOverlayPipelineState = applyOverlayPipelineState,
              let cgImage = image.cgImage else {
            return nil
        }
        
        // ==========================================
        // [修改点 1]: 计算包含 Padding 的新画布尺寸
        // ==========================================
        let originalWidth = cgImage.width
        let originalHeight = cgImage.height
        let padding = Int(expandRadius) // 将膨胀半径作为四周的留白
        
        // 新的画布尺寸 = 原图尺寸 + 左右/上下各留出一个 padding 的空间
        let width = originalWidth + padding * 2
        let height = originalHeight + padding * 2
        
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let totalBytes = height * bytesPerRow
        
        // ==========================================
        // 1. 提取像素 & CPU 泛洪生成基础 Mask
        // ==========================================
        var rawData = [UInt8](repeating: 0, count: totalBytes)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: &rawData, width: width, height: height,
                                      bitsPerComponent: 8, bytesPerRow: bytesPerRow,
                                      space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        
        // ==========================================
        // [修改点 2]: 绘制原图时，加上 Offset(偏移量)，将其居中画在放大的画布上
        // ==========================================
        let drawRect = CGRect(x: padding, y: padding, width: originalWidth, height: originalHeight)
        context.draw(cgImage, in: drawRect)
        
        // 此时的 rawData 已经是居中带透明留白的图像了
        let maskTotalPixels = width * height
        var maskData = [UInt8](repeating: 0, count: maskTotalPixels)
        
        // 你的泛洪算法处理新的 rawData，透明边缘会自动被判定为非 mask 区域
        generate_solid_mask(imageData: rawData, width: Int32(width), height: Int32(height), maskData: &maskData)
        
        // ==========================================
        // 2. 创建 Metal 纹理 (使用新的 width 和 height)
        // ==========================================
        // (这部分代码完全不用动，因为上面的 width 和 height 已经是放大后的尺寸了)
        let rgbaDesc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: width, height: height, mipmapped: false)
        rgbaDesc.usage = [.shaderRead, .shaderWrite]
        rgbaDesc.storageMode = .shared
        guard let inTexture = device.makeTexture(descriptor: rgbaDesc) else { return nil }
        inTexture.replace(region: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0, withBytes: rawData, bytesPerRow: bytesPerRow)
        
        let r8Desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .r8Unorm, width: width, height: height, mipmapped: false)
        r8Desc.usage = [.shaderRead, .shaderWrite]
        r8Desc.storageMode = .shared
        
        guard let cpuMaskTexture = device.makeTexture(descriptor: r8Desc) else { return nil }
        cpuMaskTexture.replace(region: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0, withBytes: maskData, bytesPerRow: width)
        
        guard let dilatedMaskTexture = device.makeTexture(descriptor: r8Desc) else { return nil }
        guard let outTexture = device.makeTexture(descriptor: rgbaDesc) else { return nil }
        
        // ==========================================
        // 3. 开启 Command Buffer 并派发计算任务
        // ==========================================
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeComputeCommandEncoder() else { return nil }
        
        // (这里的线程组计算也是基于新的 width/height，直接复用原代码即可)
        let w = dilatePipelineState.threadExecutionWidth
        let h = dilatePipelineState.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSizeMake(w, h, 1)
        let threadgroupsPerGrid = MTLSizeMake((width + w - 1) / w, (height + h - 1) / h, 1)
        
        // ... [渲染 Pass 1] 和 [渲染 Pass 2] 保持原样 ...
        var currentRadius = expandRadius
        encoder.setComputePipelineState(dilatePipelineState)
        encoder.setTexture(cpuMaskTexture, index: 0)
        encoder.setTexture(dilatedMaskTexture, index: 1)
        encoder.setBytes(&currentRadius, length: MemoryLayout<Int32>.stride, index: 0)
        encoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        var overlayParams = OverlayColor(color: SIMD4<Float>(Float(r), Float(g), Float(b), Float(a)))
        
        encoder.setComputePipelineState(applyOverlayPipelineState)
        encoder.setTexture(inTexture, index: 0)
        encoder.setTexture(dilatedMaskTexture, index: 1)
        encoder.setTexture(outTexture, index: 2)
        encoder.setBytes(&overlayParams, length: MemoryLayout<OverlayColor>.stride, index: 0)
        encoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        
        encoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        
        var outRawData = [UInt8](repeating: 0, count: totalBytes)
        outTexture.getBytes(&outRawData, bytesPerRow: bytesPerRow, from: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0)
        
        guard let outContext = CGContext(data: &outRawData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
              let outCGImage = outContext.makeImage() else { return nil }
        
        return UIImage(cgImage: outCGImage, scale: image.scale, orientation: image.imageOrientation)
    }
}
