//
//  MetalIconProcessor.swift
//  LTApp
//
//  Created by Renjun Li on 2025/12/3.
//


import Kingfisher
import UIKit

/// Kingfisher 自定义处理器：连接 Metal 处理管线
struct MetalIconProcessor: ImageProcessor {
    
    // 1. 唯一标识符
    // Kingfisher 用它来生成缓存 Key。
    // 如果你修改了 Metal 算法，记得修改版本号（如 v2），这样用户会自动重新处理图片。
    var identifier = "com.myapp.metal.icon.processor.v1"
    
    // 加粗力度
    let thickness: Int
    
    init(thickness: Int = 1) {
        self.thickness = thickness
        // 将参数加入标识符，确保不同力度的图片缓存不同
        self.identifier = "com.myapp.metal.icon.processor.v1_thickness_\(thickness)"
    }
    
    // 2. 处理方法
    func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        switch item {
        case .image(let image):
            // 这里运行在 Kingfisher 的后台处理队列中，可以安全地阻塞等待 Metal 结果
            var processedImage: UIImage?
            let semaphore = DispatchSemaphore(value: 0)
            
            // 调用我们之前写好的 Metal 单例
            MetalImageProcessor.shared.process(image, thickness: thickness) { result in
                processedImage = result
                semaphore.signal()
            }
            
            // 等待 Metal 处理完成
            // 设置一个合理的超时时间（例如 3 秒），防止异常情况卡死
            let waitResult = semaphore.wait(timeout: .now() + 3.0)
            
            if waitResult == .timedOut {
                print("Metal Processing Timed Out")
                return image // 超时返回原图，或者 return nil
            }
            
            return processedImage ?? image // 如果处理失败，降级显示原图
            
        case let .data(data):
            guard let image = UIImage(data: data) else { return nil }
            // 这里运行在 Kingfisher 的后台处理队列中，可以安全地阻塞等待 Metal 结果
            var processedImage: UIImage?
            let semaphore = DispatchSemaphore(value: 0)
            
            // 调用我们之前写好的 Metal 单例
            MetalImageProcessor.shared.process(image, thickness: thickness) { result in
                processedImage = result
                semaphore.signal()
            }
            
            // 等待 Metal 处理完成
            // 设置一个合理的超时时间（例如 3 秒），防止异常情况卡死
            let waitResult = semaphore.wait(timeout: .now() + 3.0)
            
            if waitResult == .timedOut {
                print("Metal Processing Timed Out")
                return image // 超时返回原图，或者 return nil
            }
            
            return processedImage ?? image // 如果处理失败，降级显示原图
        }
    }
}
