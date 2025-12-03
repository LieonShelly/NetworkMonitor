//
//  UImageExtensions.swift
//  LTApp
//
//  Created by Renjun Li on 2025/12/3.
//

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
