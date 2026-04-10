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
    private var renderPipelineState: MTLRenderPipelineState?
    private let realtimeLock = NSLock()
    private var cachedInTexture: MTLTexture?
    private var cachedDilatedMaskTexture: MTLTexture?
    private var cachedOutTexture: MTLTexture?
    private var cachedImageScale: CGFloat = 1.0
    private var cachedImageOrientation: UIImage.Orientation = .up
    private var isPrepared: Bool = false
    
    public private(set) var isPreparing: Bool = false
    
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
                if let vertexFunc = library.makeFunction(name: "quad_vertex_main"),
                   let fragmentFunc = library.makeFunction(name: "overlay_fragment_main") {
                    
                    let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
                    renderPipelineDescriptor.vertexFunction = vertexFunc
                    renderPipelineDescriptor.fragmentFunction = fragmentFunc
                    renderPipelineDescriptor.colorAttachments[0].pixelFormat = .rgba8Unorm
                    
                    renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
                    renderPipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
                    renderPipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
                    renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
                    renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
                    renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
                    renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
                    
                    do {
                        self.renderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
                    } catch {
                        print("Render Pipeline 初始化失败: \(error)")
                    }
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
    public func prepareForRealtimeRenderingAsync(
        image: UIImage,
        expandRadius: Int32 = 30
    ) async -> Bool {
        isPreparing = true
        let success = await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self else {
                    continuation.resume(returning: false)
                    return
                }
                let result = self.prepareForRealtimeRendering(image: image, expandRadius: expandRadius)
                continuation.resume(returning: result)
            }
        }
        isPreparing = false
        if success, overlayColor != nil {
          await MainActor.run {
                mtkView?.setNeedsDisplay()
            }
        }
        return success
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
        rgbaDesc.usage = [.shaderRead, .shaderWrite, .renderTarget]
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
    
    func renderToView() {
        realtimeLock.lock()
        let inTex = cachedInTexture
        let maskTex = cachedDilatedMaskTexture
        let prepared = isPrepared
        let color = overlayColor
        realtimeLock.unlock()
        
        guard prepared, let inTex, let maskTex, let color,
              let commandQueue = commandQueue,
              let mtkView = mtkView,
              let drawable = mtkView.currentDrawable else { return }
        
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        var overlayParams = OverlayColor(color: SIMD4<Float>(Float(r), Float(g), Float(b), Float(a)))
        
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        
        let viewW = Float(drawable.texture.width)
        let viewH = Float(drawable.texture.height)
        let imgW = Float(inTex.width)
        let imgH = Float(inTex.height)

        let scaleFitX = viewW / imgW
        let scaleFitY = viewH / imgH
        var finalScale = min(scaleFitX, scaleFitY)
        finalScale = min(finalScale, 1.0)
        let drawW = imgW * finalScale
        let drawH = imgH * finalScale
        
        let ndcScaleX = drawW / viewW
        let ndcScaleY = drawH / viewH

        let vertices: [Float] = [
            -ndcScaleX, -ndcScaleY,
             ndcScaleX, -ndcScaleY,
            -ndcScaleX,  ndcScaleY,
             ndcScaleX,  ndcScaleY
        ]

        let texCoords: [Float] = [
            0.0, 1.0,
            1.0, 1.0,
            0.0, 0.0,
            1.0, 0.0
        ]

        guard let renderPassDescriptor = mtkView.currentRenderPassDescriptor,
              let renderPipelineState = renderPipelineState,
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }

        renderEncoder.setRenderPipelineState(renderPipelineState)
        renderEncoder.setVertexBytes(vertices, length: MemoryLayout<Float>.size * vertices.count, index: 0)
        renderEncoder.setVertexBytes(texCoords, length: MemoryLayout<Float>.size * texCoords.count, index: 1)
        renderEncoder.setFragmentTexture(inTex, index: 0)
        renderEncoder.setFragmentTexture(maskTex, index: 1)
        renderEncoder.setFragmentBytes(&overlayParams, length: MemoryLayout<OverlayColor>.stride, index: 0)
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()
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
              let renderPipelineState = renderPipelineState else { return nil }
        
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        var overlayParams = OverlayColor(color: SIMD4<Float>(Float(r), Float(g), Float(b), Float(a)))
        
        // 离屏 render pass → cachedOutTexture
        let renderPassDesc = MTLRenderPassDescriptor()
        renderPassDesc.colorAttachments[0].texture = outTex
        renderPassDesc.colorAttachments[0].loadAction = .clear
        renderPassDesc.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        renderPassDesc.colorAttachments[0].storeAction = .store
        
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDesc) else { return nil }
        
        // 全屏 quad 覆盖整个 outTexture
        let vertices: [Float] = [
            -1.0, -1.0,
             1.0, -1.0,
            -1.0,  1.0,
             1.0,  1.0
        ]
        let texCoords: [Float] = [
            0.0, 1.0,
            1.0, 1.0,
            0.0, 0.0,
            1.0, 0.0
        ]
        
        renderEncoder.setRenderPipelineState(renderPipelineState)
        renderEncoder.setVertexBytes(vertices, length: MemoryLayout<Float>.size * vertices.count, index: 0)
        renderEncoder.setVertexBytes(texCoords, length: MemoryLayout<Float>.size * texCoords.count, index: 1)
        renderEncoder.setFragmentTexture(inTex, index: 0)
        renderEncoder.setFragmentTexture(maskTex, index: 1)
        renderEncoder.setFragmentBytes(&overlayParams, length: MemoryLayout<OverlayColor>.stride, index: 0)
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        // 从 outTexture 回读像素
        let width = outTex.width
        let height = outTex.height
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
