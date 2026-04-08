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

// 定义一个简单的结构体用于 BFS 队列，使用 Int16 节省内存
private struct FloodPoint {
    var x: Int16
    var y: Int16
}

/// 生成闭合区域的 Mask
/// - Parameters:
///   - imageData: 原始 RGBA 图像像素数据的只读指针
///   - width: 图像宽度
///   - height: 图像高度
///   - maskData: 输出的单通道 Mask 缓冲区的可写指针 (大小需为 width * height)
@_cdecl("generate_solid_mask")
public func generate_solid_mask(imageData: UnsafePointer<UInt8>, width: Int32, height: Int32, maskData: UnsafeMutablePointer<UInt8>) {
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
private func applyConvexHullFallback(points: [CGPoint], maskData: UnsafeMutablePointer<UInt8>, width: Int, height: Int) {
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
private func computeConvexHull(points: [CGPoint]) -> [CGPoint] {
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


/// 用于记录最近图形点坐标的结构体
private struct Point16 {
    var x: Int16
    var y: Int16
    @inline(__always) var isValid: Bool { x >= 0 }
}

/// 基于 JFA (跳跃泛洪算法) 的终极形态学膨胀
/// 完美支持任意大小的半径 (1 ~ 1000+)，保持绝对圆滑且性能恒定
private func expandMask(maskData: UnsafeMutablePointer<UInt8>, width: Int, height: Int, radius: Int) {
    if radius <= 0 { return }
    let w = width
    let h = height
    let total = w * h
    
    // 1. 分配两块原生的连续内存作为种子缓冲区 (避免 Swift Array 开销)
    let seeds = UnsafeMutablePointer<Point16>.allocate(capacity: total)
    let nextSeeds = UnsafeMutablePointer<Point16>.allocate(capacity: total)
    defer {
        seeds.deallocate()
        nextSeeds.deallocate()
    }
    
    // 2. 初始化种子
    let invalidPoint = Point16(x: -1, y: -1)
    for i in 0..<total {
        if maskData[i] > 0 {
            seeds[i] = Point16(x: Int16(i % w), y: Int16(i / w)) // 记录自身坐标
        } else {
            seeds[i] = invalidPoint
        }
    }
    
    // 3. JFA 核心迭代逻辑
    var step = max(w, h) / 2
    var readPtr = seeds
    var writePtr = nextSeeds
    
    while step >= 1 {
        for y in 0..<h {
            for x in 0..<w {
                let idx = y * w + x
                var bestSeed = readPtr[idx]
                var minDistSq = Int.max
                
                // 计算当前最佳距离
                if bestSeed.isValid {
                    let dx = x - Int(bestSeed.x)
                    let dy = y - Int(bestSeed.y)
                    minDistSq = dx * dx + dy * dy
                }
                
                // 探测周围 8 个跳跃方向
                let offsets = [-step, 0, step]
                for dyStep in offsets {
                    let ny = y + dyStep
                    if ny < 0 || ny >= h { continue }
                    
                    for dxStep in offsets {
                        if dxStep == 0 && dyStep == 0 { continue }
                        
                        let nx = x + dxStep
                        if nx < 0 || nx >= w { continue }
                        
                        let neighborSeed = readPtr[ny * w + nx]
                        if neighborSeed.isValid {
                            let distX = x - Int(neighborSeed.x)
                            let distY = y - Int(neighborSeed.y)
                            let distSq = distX * distX + distY * distY
                            
                            // 如果邻居记录的种子离我更近，更新我的种子
                            if distSq < minDistSq {
                                minDistSq = distSq
                                bestSeed = neighborSeed
                            }
                        }
                    }
                }
                writePtr[idx] = bestSeed
            }
        }
        
        // 交换读写指针
        let temp = readPtr
        readPtr = writePtr
        writePtr = temp
        
        // 步长减半
        step /= 2
    }
    
    // 4. 阈值化：只要距离小于等于半径，就涂白
    let rSq = radius * radius
    for i in 0..<total {
        let seed = readPtr[i]
        if seed.isValid {
            let x = i % w
            let y = i / w
            let dx = x - Int(seed.x)
            let dy = y - Int(seed.y)
            
            // 完美的欧几里得圆形判定
            if dx * dx + dy * dy <= rSq {
                maskData[i] = 255
            }
        }
    }
}


/// 按比例中心放大图像，并获取像素数据用于 Mask 生成
func getScaledImageData(from image: UIImage, scaleFactor: CGFloat = 1.1) -> [UInt8]? {
    guard let cgImage = image.cgImage else { return nil }
    
    let width = cgImage.width
    let height = cgImage.height
    let bytesPerPixel = 4
    let bytesPerRow = width * bytesPerPixel
    let totalBytes = height * bytesPerRow
    
    var rawData = [UInt8](repeating: 0, count: totalBytes)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    
    guard let context = CGContext(data: &rawData,
                                  width: width, height: height,
                                  bitsPerComponent: 8,
                                  bytesPerRow: bytesPerRow,
                                  space: colorSpace,
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
    
    // 1. 将原点移动到画布中心
    context.translateBy(x: CGFloat(width) / 2.0, y: CGFloat(height) / 2.0)
    // 2. 执行放大 (比如 1.1)
    context.scaleBy(x: scaleFactor, y: scaleFactor)
    // 3. 将原点移回，以便正确绘制图像
    context.translateBy(x: -CGFloat(width) / 2.0, y: -CGFloat(height) / 2.0)
    
    // 4. 绘制原图 (此时它已经被放大并居中了)
    let drawRect = CGRect(x: 0, y: 0, width: width, height: height)
    context.draw(cgImage, in: drawRect)
    
    return rawData
}
