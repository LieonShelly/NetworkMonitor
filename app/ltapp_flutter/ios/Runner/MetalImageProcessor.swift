//
//  MetalImageProcessor.swift
//  LTApp
//
//  Created by Renjun Li on 2025/12/3.
//

@preconcurrency import UIKit
import MetalKit

class MetalImageProcessor: @unchecked Sendable {
    static let shared = MetalImageProcessor()
    private let device: MTLDevice?
    private let commandQueue: MTLCommandQueue?
    private let textureLoader: MTKTextureLoader?
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
        
        if let cropFunc = library.makeFunction(name: "detectContentBounds") {
            self.cropPipelineState = try? device.makeComputePipelineState(function: cropFunc)
        } else {
            self.cropPipelineState = nil
        }
        
        if let thickenFunc = library.makeFunction(name: "thickenAndRemoveBackground") {
            self.thickenPipelineState = try? device.makeComputePipelineState(function: thickenFunc)
        } else {
            self.thickenPipelineState = nil
        }
    }
    
    struct BoundingBoxResult {
        var minX: UInt32
        var minY: UInt32
        var maxX: UInt32
        var maxY: UInt32
    }
    
    func processSync(_ image: UIImage, thickness: Int = 1) -> UIImage? {
        guard let device = device,
              let commandQueue = commandQueue,
              let cropPipelineState = cropPipelineState,
              let processPipelineState = thickenPipelineState,
              let textureLoader = textureLoader,
              let cgImage = image.cgImage else {
            return nil
        }
        
        let options: [MTKTextureLoader.Option: Any] = [.SRGB: false, .origin: MTKTextureLoader.Origin.topLeft]
        guard let originalTexture = try? textureLoader.newTexture(cgImage: cgImage, options: options) else {
            return nil
        }
        
        var initData = BoundingBoxResult(minX: UInt32(originalTexture.width), minY: UInt32(originalTexture.height), maxX: 0, maxY: 0)
        guard let buffer = device.makeBuffer(bytes: &initData, length: MemoryLayout<BoundingBoxResult>.stride, options: .storageModeShared) else {
            return nil
        }
        
        guard let commandBuffer1 = commandQueue.makeCommandBuffer(),
              let encoder1 = commandBuffer1.makeComputeCommandEncoder() else {
            return nil
        }
        
        encoder1.setComputePipelineState(cropPipelineState)
        encoder1.setTexture(originalTexture, index: 0)
        encoder1.setBuffer(buffer, offset: 0, index: 0)
        dispatchCompatible(encoder: encoder1, pipeline: cropPipelineState, width: originalTexture.width, height: originalTexture.height)
        encoder1.endEncoding()
        
        commandBuffer1.commit()
        commandBuffer1.waitUntilCompleted()
        
        let ptr = buffer.contents().bindMemory(to: BoundingBoxResult.self, capacity: 1)
        let result = ptr.pointee
        
        if result.maxX < result.minX || result.maxY < result.minY {
            return image
        }
        
        let cropRect = MTLRegionMake2D(Int(result.minX), Int(result.minY),
                                       Int(result.maxX - result.minX + 1),
                                       Int(result.maxY - result.minY + 1))
        
        return runProcessPassSync(device: device,
                                  commandQueue: commandQueue,
                                  pipeline: processPipelineState,
                                  originalTexture: originalTexture,
                                  cropRegion: cropRect,
                                  thickness: thickness,
                                  originalScale: image.scale,
                                  orientation: image.imageOrientation)
    }
    
    private func runProcessPassSync(device: MTLDevice,
                                    commandQueue: MTLCommandQueue,
                                    pipeline: MTLComputePipelineState,
                                    originalTexture: MTLTexture,
                                    cropRegion: MTLRegion,
                                    thickness: Int,
                                    originalScale: CGFloat,
                                    orientation: UIImage.Orientation) -> UIImage? {
        
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm,
                                                                  width: cropRegion.size.width,
                                                                  height: cropRegion.size.height,
                                                                  mipmapped: false)
        descriptor.usage = [.shaderRead, .shaderWrite]
        
        guard let outputTexture = device.makeTexture(descriptor: descriptor),
              let commandBuffer2 = commandQueue.makeCommandBuffer(),
              let encoder2 = commandBuffer2.makeComputeCommandEncoder() else {
            return nil
        }
        
        encoder2.setComputePipelineState(pipeline)
        encoder2.setTexture(originalTexture, index: 0)
        encoder2.setTexture(outputTexture, index: 1)
        
        var radius = Int32(thickness)
        encoder2.setBytes(&radius, length: MemoryLayout<Int32>.size, index: 0)
        
        var offset = SIMD2<UInt32>(UInt32(cropRegion.origin.x), UInt32(cropRegion.origin.y))
        encoder2.setBytes(&offset, length: MemoryLayout<SIMD2<UInt32>>.size, index: 1)
        
        dispatchCompatible(encoder: encoder2, pipeline: pipeline, width: outputTexture.width, height: outputTexture.height)
        encoder2.endEncoding()
        
        commandBuffer2.commit()
        commandBuffer2.waitUntilCompleted()
        
        return self.textureToImage(texture: outputTexture, scale: originalScale, orientation: orientation)
    }
    
    private func dispatchCompatible(encoder: MTLComputeCommandEncoder, pipeline: MTLComputePipelineState, width: Int, height: Int) {
        let w = pipeline.threadExecutionWidth
        let h = pipeline.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSizeMake(w, h, 1)
        let threadgroupsPerGrid = MTLSizeMake((width + w - 1) / w, (height + h - 1) / h, 1)
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
        
        return data.withUnsafeMutableBytes { bufferPointer in
            guard let baseAddress = bufferPointer.baseAddress else { return nil }
            
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
            
            guard let context = CGContext(data: baseAddress,
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
}
