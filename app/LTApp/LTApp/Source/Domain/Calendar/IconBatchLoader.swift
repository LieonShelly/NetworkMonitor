//
//  IconBatchLoader.swift
//  LTApp
//
//  Created by Renjun Li on 2025/12/3.
//

import Foundation
import Kingfisher
import UIKit

class IconBatchLoader {
    nonisolated(unsafe) static let shared = IconBatchLoader()
    
    // 限制最大并发数，防止 GPU 瞬时压力过大
    // 建议设置为 4-6，因为 Metal command queue 也是串行/并发混合的
    private let prefetcherQueue = DispatchQueue(label: "com.myapp.prefetch", qos: .utility)
    
    init() {
        // 配置全局下载器（可选）
        // KingfisherManager.shared.downloader.maxConcurrentDownloads = 6
    }
    
    /// 批量下载并处理图片
    /// - Parameters:
    ///   - urls: 图片 URL 列表
    ///   - completion: 所有任务完成后的回调
    func startBatchProcessing(urls: [URL], completion: @escaping () -> Void) {
        // 定义我们刚才写的 Processor
        let processor = MetalIconProcessor(thickness: 1)
        
        // 创建 Prefetcher
        // Kingfisher 会：下载 -> 调用 Processor (Metal) -> 缓存结果
        let prefetcher = ImagePrefetcher(
            urls: urls,
            options: [
                .processor(processor), // 关键：注入 Metal 处理器
                .cacheOriginalImage,   // 可选：是否同时也缓存原图
                .backgroundDecode      // 在后台解码
            ],
            completionHandler: { skipped, failed, completed in
                print("Batch finished: \(completed.count) completed, \(failed.count) failed.")
                completion()
            }
        )
        
        prefetcher.start()
    }
}
