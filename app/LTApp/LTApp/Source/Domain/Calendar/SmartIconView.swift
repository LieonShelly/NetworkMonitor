//
//  SmartIconView.swift
//  LTApp
//
//  Created by Renjun Li on 2025/12/3.
//

import SwiftUI

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
