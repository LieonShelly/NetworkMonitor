//
//  MetalCropper.swift
//  LTApp
//
//  Created by Renjun Li on 2025/12/3.
//


import UIKit
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
        
        // 加载 Shader
        guard let device = device,
              let library = device.makeDefaultLibrary(),
              let function = library.makeFunction(name: "detectContentBounds") else {
            self.pipelineState = nil
            return
        }
        self.pipelineState = try? device.makeComputePipelineState(function: function)
    }
    
    // 定义与 Shader 对应的结构体布局
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
        //以此确保颜色空间正确，避免红蓝反转
        let options: [MTKTextureLoader.Option: Any] = [.SRGB: false, .origin: MTKTextureLoader.Origin.topLeft]
        guard let texture = try? textureLoader.newTexture(cgImage: cgImage, options: options) else {
            completion(nil)
            return
        }
        
        // 2. 准备结果 Buffer
        // 初始化：Min 设为最大值，Max 设为 0，反向初始化以便 update
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
        
        computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        computeEncoder.endEncoding()
        
        // 5. 等待 GPU 完成
        commandBuffer.addCompletedHandler { _ in
            let ptr = buffer.contents().bindMemory(to: BoundingBoxResult.self, capacity: 1)
            let result = ptr.pointee
            
            // 检查是否找到了有效内容
            if result.maxX < result.minX || result.maxY < result.minY {
                // 没找到内容（全是白或全是透），返回原图
                DispatchQueue.main.async { completion(image) }
                return
            }
            
            // 6. 执行裁切 (在 CPU 上做这一步，因为只是切一下 Rect，非常快)
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
}

import SwiftUI

struct MetalSmartIconView: View {
    let originalImage: UIImage
    @State private var processedImage: UIImage?
    let thicknessLevel: Int = 10
    
    var body: some View {
        Group {
            VStack {
                VStack {
                    Text("原图")
                    Image(uiImage: originalImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .border(.blue)
                        .frame(width: 40, height: 40)
                }
               
                
                if let img = processedImage {
                    VStack {
                        Text("裁剪+腐蚀处理之后：")
                        Image(uiImage: img)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .border(.red)
                            .frame(width: 40, height: 40)
                    }
                } else {
                    Color.clear
                }
            }
          
        }
       
        .onAppear {
            // 使用 Metal 进行高性能裁切
            MetalCropper.shared.cropImage(originalImage) { result in
                MetalLineThickener.shared.thicken(result!, thickness: thicknessLevel) { thickened in
                    DispatchQueue.main.async {
                        self.processedImage = thickened
                    }
                }
            }
            
         
        }
    }
}


import UIKit
import CoreGraphics

extension UIImage {
    /// 自动去除图片周围的透明或白色留白
    func trimmingTransparentPixels() -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        
        let width = cgImage.width
        let height = cgImage.height
        
        // 获取图片的像素数据
        guard let dataProvider = cgImage.dataProvider,
              let data = dataProvider.data,
              let ptr = CFDataGetBytePtr(data) else {
            return nil
        }
        
        let bytesPerPixel = 4 // RGBA
        let bytesPerRow = cgImage.bytesPerRow
        
        var minX = width
        var minY = height
        var maxX = 0
        var maxY = 0
        var foundContent = false
        
        // 遍历所有像素 (这一步在主线程处理大图可能会卡，建议在后台线程做)
        for y in 0..<height {
            for x in 0..<width {
                let offset = (y * bytesPerRow) + (x * bytesPerPixel)
                
                let red = ptr[offset]
                let green = ptr[offset + 1]
                let blue = ptr[offset + 2]
                let alpha = ptr[offset + 3]
                
                // 判断逻辑：
                // 1. Alpha > 0 (不是全透明)
                // 2. 且 RGB 不是全白 (如果是JPG白色背景，通常 RGB 都在 240 以上)
                // 这里设定阈值：如果亮度低于 250，或者是透明度大于 0，我们认为它是内容
                // 针对你的鸭子图（黑线），我们需要找“不白”的地方
                
                let isWhite = (red > 240 && green > 240 && blue > 240)
                let isTransparent = (alpha == 0)
                
                if !isTransparent && !isWhite {
                    if x < minX { minX = x }
                    if x > maxX { maxX = x }
                    if y < minY { minY = y }
                    if y > maxY { maxY = y }
                    foundContent = true
                }
            }
        }
        
        // 如果全是空白，直接返回原图
        if !foundContent { return self }
        
        // 构建裁切区域 (加一点点 padding 防止切得太死)
        let rect = CGRect(x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1)
        
        // 执行裁切
        guard let croppedCGImage = cgImage.cropping(to: rect) else { return nil }
        
        // 保持原图的 Scale (比如 2x, 3x) 和方向
        return UIImage(cgImage: croppedCGImage, scale: self.scale, orientation: self.imageOrientation)
    }
}

struct SmartIconView: View {
    let originalImage: UIImage // 服务端下发的图片
    @State private var processedImage: UIImage?
    
    var body: some View {
        Group {
            if let img = processedImage {
                // 显示处理后的“紧凑”图片
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                // 还没处理好时，先显示占位符或原图
                Color.clear
            }
        }
        .frame(width: 24, height: 24) // 你的目标小尺寸
        .onAppear {
            // 异步执行裁切，防止卡顿
            processImage()
        }
    }
    
    private func processImage() {
        // 放到后台队列去计算像素，不阻塞主线程
        DispatchQueue.global(qos: .userInitiated).async {
            // 调用上面写的扩展方法
            let trimmed = originalImage.trimmingTransparentPixels()
            
            DispatchQueue.main.async {
                self.processedImage = trimmed ?? originalImage
            }
        }
    }
}
