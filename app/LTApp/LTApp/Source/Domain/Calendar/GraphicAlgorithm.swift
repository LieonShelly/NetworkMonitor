//
//  FloodPoint.swift
//  LTApp
//
//  Created by Renjun Li on 2026/4/8.
//


import Foundation
import CoreGraphics
import UIKit
import Accelerate

struct GraphicAlgorithm {
    
    /// 生成闭合区域的 Mask
    public static func generateSolidMask(imageData: UnsafePointer<UInt8>, width: Int32, height: Int32, maskData: UnsafeMutablePointer<UInt8>) {
        let w = Int(width)
        let h = Int(height)
        let totalPixels = w * h
        
        if totalPixels <= 0 { return }
        
        // --- 阶段 1：统计原始笔触面积 ---
        var strokeArea = 0
        var activePoints: [CGPoint] = [] // 用于可能的凸包计算
        
        for i in 0..<totalPixels {
            if imageData[i * 4 + 3] > 0 { // alpha > 0
                strokeArea += 1
                // 每隔几个像素采样一次即可，没必要记录所有点，优化凸包性能
                if i % 5 == 0 {
                    activePoints.append(CGPoint(x: i % w, y: i / w))
                }
            }
        }
        

        // 1. 初始化：假设所有区域都是内部有效区域 (255)
        // 使用 memset 是最快的方式
        memset(maskData, 255, totalPixels)

        // 2. 分配 BFS 队列内存
        // 使用 UnsafeMutablePointer 分配连续内存，避免 Swift Array 的扩容和对象生命周期开销，保证与 C 一样的性能
        let queue = UnsafeMutablePointer<FloodPoint>.allocate(capacity: totalPixels)
        // 确保函数退出时释放内存，无论是否发生异常
        defer { queue.deallocate() }
        
        var head = 0
        var tail = 0

        // 辅助函数：将透明边缘点加入队列
        @inline(__always)
        func checkAndEnqueue(x: Int, y: Int) {
            let index = y * w + x
            // RGBA 格式，alpha 通道的偏移量是 3
            if imageData[index * 4 + 3] == 0 {
                maskData[index] = 0 // 标记为外部背景
                queue[tail] = FloodPoint(x: Int16(x), y: Int16(y))
                tail += 1
            }
        }

        // 3. 将四周边缘的透明像素作为种子，推入队列
        // 扫描上下边缘
        for x in 0..<w {
            checkAndEnqueue(x: x, y: 0)
            checkAndEnqueue(x: x, y: h - 1)
        }
        // 扫描左右边缘 (避开已扫描的四个角)
        if h > 2 {
            for y in 1..<(h - 1) {
                checkAndEnqueue(x: 0, y: y)
                checkAndEnqueue(x: w - 1, y: y)
            }
        }

        // 4. 开始向内泛洪 (BFS)
        let dx = [-1, 1, 0, 0]
        let dy = [0, 0, -1, 1]

        while head < tail {
            let p = queue[head]
            head += 1

            let px = Int(p.x)
            let py = Int(p.y)

            // 遍历 4 个方向的邻居
            for i in 0..<4 {
                let nx = px + dx[i]
                let ny = py + dy[i]

                // 越界检查
                if nx >= 0 && nx < w && ny >= 0 && ny < h {
                    let idx = ny * w + nx
                    
                    // 如果邻居仍被标记为内部(255)，且其本身也是透明的(alpha == 0)
                    if maskData[idx] == 255 && imageData[idx * 4 + 3] == 0 {
                        maskData[idx] = 0 // 确认为外部背景
                        queue[tail] = FloodPoint(x: Int16(nx), y: Int16(ny))
                        tail += 1
                    }
                }
            }
        }
        
        // --- 阶段 3：校验结果并执行兜底 (Fallback) ---
            var maskArea = 0
            for i in 0..<totalPixels {
                if maskData[i] == 255 { maskArea += 1 }
            }

            // 判定：如果填充面积几乎没有增加（小于原始轮廓的 1.05 倍），认为泛洪失败
            let fillRatio = Double(maskArea) / Double(max(strokeArea, 1))
            
            if fillRatio < 1.05 && activePoints.count > 3 {
                print("MetalProcessor: 泛洪失败 (Ratio: \(fillRatio)), 触发凸包兜底策略")
                applyConvexHullFallback(points: activePoints, maskData: maskData, width: w, height: h)
            }
    }

    /// 使用 CoreGraphics 将凸包多边形绘制到 Mask 缓冲区
    private static func applyConvexHullFallback(points: [CGPoint], maskData: UnsafeMutablePointer<UInt8>, width: Int, height: Int) {
        let hull = computeConvexHull(points: points)
        if hull.count < 3 { return }
        
        // 创建一个单通道的灰度 CoreGraphics 上下文，直接绑定到我们的 maskData 内存！
        let colorSpace = CGColorSpaceCreateDeviceGray()
        guard let context = CGContext(data: maskData,
                                      width: width, height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: width,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.none.rawValue) else { return }
        
        // 清空之前的错误泛洪记录
        context.setFillColor(UIColor.black.cgColor) // 黑色代表 0
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        
        // 绘制凸包路径
        context.setFillColor(UIColor.white.cgColor) // 白色代表 255
        context.beginPath()
        context.move(to: hull[0])
        for i in 1..<hull.count {
            context.addLine(to: hull[i])
        }
        context.closePath()
        context.fillPath() // 一键光栅化！
    }

    /// 经典的 Monotone Chain 凸包算法
    private static func computeConvexHull(points: [CGPoint]) -> [CGPoint] {
        let sorted = points.sorted { $0.x == $1.x ? $0.y < $1.y : $0.x < $1.x }
        var lower: [CGPoint] = []
        for p in sorted {
            while lower.count >= 2 {
                let a = lower[lower.count - 2], b = lower[lower.count - 1]
                if (b.x - a.x) * (p.y - a.y) - (b.y - a.y) * (p.x - a.x) <= 0 { lower.removeLast() }
                else { break }
            }
            lower.append(p)
        }
        var upper: [CGPoint] = []
        for p in sorted.reversed() {
            while upper.count >= 2 {
                let a = upper[upper.count - 2], b = upper[upper.count - 1]
                if (b.x - a.x) * (p.y - a.y) - (b.y - a.y) * (p.x - a.x) <= 0 { upper.removeLast() }
                else { break }
            }
            upper.append(p)
        }
        lower.removeLast()
        upper.removeLast()
        return lower + upper
    }


}

private struct FloodPoint {
    var x: Int16
    var y: Int16
}
