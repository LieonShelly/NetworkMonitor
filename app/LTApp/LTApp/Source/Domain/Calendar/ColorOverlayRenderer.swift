import UIKit
import MetalKit

private struct OverlayColor {
    var color: SIMD4<Float>
}

@Observable
public class ColorOverlayRenderer: @unchecked Sendable {
    
    public static let shared = ColorOverlayRenderer()
    
    private var device: MTLDevice?
    private var commandQueue: MTLCommandQueue?
    
    private var dilatePipelineState: MTLComputePipelineState?
    private var applyOverlayPipelineState: MTLComputePipelineState?
    
    private let realtimeLock = NSLock()
    private var cachedInTexture: MTLTexture?
    private var cachedDilatedMaskTexture: MTLTexture?
    private var cachedOutTexture: MTLTexture?
    private var cachedImageScale: CGFloat = 1.0
    private var cachedImageOrientation: UIImage.Orientation = .up
    private var isPrepared: Bool = false
    
    public var overlayColor: UIColor? {
        didSet {
            guard isPrepared, overlayColor != nil else {
                return
            }
            mtkView?.setNeedsDisplay()
        }
    }
    
    weak var mtkView: MTKView?
    
    public init() {
        self.device = MTLCreateSystemDefaultDevice()
        self.commandQueue = device?.makeCommandQueue()
        
        if let device = device,
           let library = device.makeDefaultLibrary() {
            do {
                if let dilateFunc = library.makeFunction(name: "dilate_mask") {
                    self.dilatePipelineState = try device.makeComputePipelineState(function: dilateFunc)
                }
                if let overlayFunc = library.makeFunction(name: "apply_color_overlay") {
                    self.applyOverlayPipelineState = try device.makeComputePipelineState(function: overlayFunc)
                }
            } catch {
                print("Metal Pipeline 初始化失败: \(error)")
            }
        }
    }
    
    public func cleanupRealtimeCache() {
        realtimeLock.lock()
        defer { realtimeLock.unlock() }
        cachedInTexture = nil
        cachedDilatedMaskTexture = nil
        cachedOutTexture = nil
        isPrepared = false
    }
    
    @discardableResult
    public func prepareForRealtimeRendering(
        image: UIImage,
        expandRadius: Int32 = 30
    ) -> Bool {
        realtimeLock.lock()
        defer { realtimeLock.unlock() }
        
        cachedInTexture = nil
        cachedDilatedMaskTexture = nil
        cachedOutTexture = nil
        isPrepared = false
        
        guard let device = device,
              let commandQueue = commandQueue,
              let dilatePipelineState = dilatePipelineState,
              let cgImage = image.cgImage else { return false }
        
        let originalWidth = cgImage.width
        let originalHeight = cgImage.height
        let padding = Int(expandRadius)
        let width = originalWidth + padding * 2
        let height = originalHeight + padding * 2
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let totalBytes = height * bytesPerRow
        
        var rawData = [UInt8](repeating: 0, count: totalBytes)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: &rawData, width: width, height: height,
                                      bitsPerComponent: 8, bytesPerRow: bytesPerRow,
                                      space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return false }
        
        let drawRect = CGRect(x: padding, y: padding, width: originalWidth, height: originalHeight)
        context.draw(cgImage, in: drawRect)
        
        let maskTotalPixels = width * height
        var maskData = [UInt8](repeating: 0, count: maskTotalPixels)
        GraphicAlgorithm.generateSolidMask(imageData: rawData, width: Int32(width), height: Int32(height), maskData: &maskData)
        
        let rgbaDesc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: width, height: height, mipmapped: false)
        rgbaDesc.usage = [.shaderRead, .shaderWrite]
        rgbaDesc.storageMode = .shared
        guard let inTexture = device.makeTexture(descriptor: rgbaDesc) else { return false }
        inTexture.replace(region: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0, withBytes: rawData, bytesPerRow: bytesPerRow)
        
        let r8Desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .r8Unorm, width: width, height: height, mipmapped: false)
        r8Desc.usage = [.shaderRead, .shaderWrite]
        r8Desc.storageMode = .shared
        
        guard let cpuMaskTexture = device.makeTexture(descriptor: r8Desc) else { return false }
        cpuMaskTexture.replace(region: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0, withBytes: maskData, bytesPerRow: width)
        
        guard let dilatedMaskTexture = device.makeTexture(descriptor: r8Desc) else { return false }
        guard let outTexture = device.makeTexture(descriptor: rgbaDesc) else { return false }
        
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeComputeCommandEncoder() else { return false }
        
        let w = dilatePipelineState.threadExecutionWidth
        let h = dilatePipelineState.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSizeMake(w, h, 1)
        let threadgroupsPerGrid = MTLSizeMake((width + w - 1) / w, (height + h - 1) / h, 1)
        
        var currentRadius = expandRadius
        encoder.setComputePipelineState(dilatePipelineState)
        encoder.setTexture(cpuMaskTexture, index: 0)
        encoder.setTexture(dilatedMaskTexture, index: 1)
        encoder.setBytes(&currentRadius, length: MemoryLayout<Int32>.stride, index: 0)
        encoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        
        encoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        cachedInTexture = inTexture
        cachedDilatedMaskTexture = dilatedMaskTexture
        cachedOutTexture = outTexture
        cachedImageScale = image.scale
        cachedImageOrientation = image.imageOrientation
        isPrepared = true
        
        return true
    }
    
   private func renderToView() {
        realtimeLock.lock()
        let inTex = cachedInTexture
        let maskTex = cachedDilatedMaskTexture
        let outTex = cachedOutTexture
        let prepared = isPrepared
        let color = overlayColor
        realtimeLock.unlock()
        
        guard prepared, let inTex, let maskTex, let outTex, let color,
              let commandQueue = commandQueue,
              let applyOverlayPipelineState = applyOverlayPipelineState,
              let mtkView = mtkView,
              let drawable = mtkView.currentDrawable else { return }
        
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        var overlayParams = OverlayColor(color: SIMD4<Float>(Float(r), Float(g), Float(b), Float(a)))
        
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        
        guard let computeEncoder = commandBuffer.makeComputeCommandEncoder() else { return }
        
        let imgW = inTex.width
        let imgH = inTex.height
        let w = applyOverlayPipelineState.threadExecutionWidth
        let h = applyOverlayPipelineState.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSizeMake(w, h, 1)
        let threadgroupsPerGrid = MTLSizeMake((imgW + w - 1) / w, (imgH + h - 1) / h, 1)
        
        computeEncoder.setComputePipelineState(applyOverlayPipelineState)
        computeEncoder.setTexture(inTex, index: 0)
        computeEncoder.setTexture(maskTex, index: 1)
        computeEncoder.setTexture(outTex, index: 2)
        computeEncoder.setBytes(&overlayParams, length: MemoryLayout<OverlayColor>.stride, index: 0)
        computeEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        computeEncoder.endEncoding()
        
        let drawableW = drawable.texture.width
        let drawableH = drawable.texture.height
        
        let copyW = min(imgW, drawableW)
        let copyH = min(imgH, drawableH)
        let dstX = max(0, (drawableW - imgW) / 2)
        let dstY = max(0, (drawableH - imgH) / 2)
        let srcX = max(0, (imgW - drawableW) / 2)
        let srcY = max(0, (imgH - drawableH) / 2)
        
        guard let blitEncoder = commandBuffer.makeBlitCommandEncoder() else { return }
        blitEncoder.copy(
            from: outTex,
            sourceSlice: 0, sourceLevel: 0,
            sourceOrigin: MTLOrigin(x: srcX, y: srcY, z: 0),
            sourceSize: MTLSize(width: copyW, height: copyH, depth: 1),
            to: drawable.texture,
            destinationSlice: 0, destinationLevel: 0,
            destinationOrigin: MTLOrigin(x: dstX, y: dstY, z: 0)
        )
        blitEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    public func exportCurrentResult() -> UIImage? {
        realtimeLock.lock()
        let inTex = cachedInTexture
        let maskTex = cachedDilatedMaskTexture
        let outTex = cachedOutTexture
        let prepared = isPrepared
        let color = overlayColor
        let scale = cachedImageScale
        let orientation = cachedImageOrientation
        realtimeLock.unlock()
        
        guard prepared, let inTex, let maskTex, let outTex, let color,
              let commandQueue = commandQueue,
              let applyOverlayPipelineState = applyOverlayPipelineState else { return nil }
        
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        var overlayParams = OverlayColor(color: SIMD4<Float>(Float(r), Float(g), Float(b), Float(a)))
        
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeComputeCommandEncoder() else { return nil }
        
        let w = applyOverlayPipelineState.threadExecutionWidth
        let h = applyOverlayPipelineState.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSizeMake(w, h, 1)
        let width = inTex.width
        let height = inTex.height
        let threadgroupsPerGrid = MTLSizeMake((width + w - 1) / w, (height + h - 1) / h, 1)
        
        encoder.setComputePipelineState(applyOverlayPipelineState)
        encoder.setTexture(inTex, index: 0)
        encoder.setTexture(maskTex, index: 1)
        encoder.setTexture(outTex, index: 2)
        encoder.setBytes(&overlayParams, length: MemoryLayout<OverlayColor>.stride, index: 0)
        encoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        
        encoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let totalBytes = height * bytesPerRow
        var outRawData = [UInt8](repeating: 0, count: totalBytes)
        outTex.getBytes(&outRawData, bytesPerRow: bytesPerRow, from: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0)
        
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let outContext = CGContext(data: &outRawData, width: width, height: height,
                                         bitsPerComponent: 8, bytesPerRow: bytesPerRow,
                                         space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
              let outCGImage = outContext.makeImage() else { return nil }
        
        return UIImage(cgImage: outCGImage, scale: scale, orientation: orientation)
    }
    
    public func applyOverlay(to image: UIImage, color: UIColor, expandRadius: Int32 = 30) -> UIImage? {
        
        guard let device = device,
              let commandQueue = commandQueue,
              let dilatePipelineState = dilatePipelineState,
              let applyOverlayPipelineState = applyOverlayPipelineState,
              let cgImage = image.cgImage else {
            return nil
        }
        
        let originalWidth = cgImage.width
        let originalHeight = cgImage.height
        let padding = Int(expandRadius) // 将膨胀半径作为四周的留白
        
        let width = originalWidth + padding * 2
        let height = originalHeight + padding * 2
        
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let totalBytes = height * bytesPerRow
        
        var rawData = [UInt8](repeating: 0, count: totalBytes)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: &rawData, width: width, height: height,
                                      bitsPerComponent: 8, bytesPerRow: bytesPerRow,
                                      space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        
        let drawRect = CGRect(x: padding, y: padding, width: originalWidth, height: originalHeight)
        context.draw(cgImage, in: drawRect)
        
        let maskTotalPixels = width * height
        var maskData = [UInt8](repeating: 0, count: maskTotalPixels)
        
        GraphicAlgorithm.generateSolidMask(imageData: rawData, width: Int32(width), height: Int32(height), maskData: &maskData)
        
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
        
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeComputeCommandEncoder() else { return nil }
        
        let w = dilatePipelineState.threadExecutionWidth
        let h = dilatePipelineState.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSizeMake(w, h, 1)
        let threadgroupsPerGrid = MTLSizeMake((width + w - 1) / w, (height + h - 1) / h, 1)
        
        
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
