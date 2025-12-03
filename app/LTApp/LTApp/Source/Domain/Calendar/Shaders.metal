//
//  BoundingBox.swift
//  LTApp
//
//  Created by Renjun Li on 2025/12/3.
//


#include <metal_stdlib>
using namespace metal;

// 用于存储边界框结果的结构体
struct BoundingBox {
    atomic_uint minX;
    atomic_uint minY;
    atomic_uint maxX;
    atomic_uint maxY;
};

// 内核函数
kernel void detectContentBounds(texture2d<float, access::read> inputTexture [[texture(0)]],
                                device BoundingBox &result [[buffer(0)]],
                                uint2 gid [[thread_position_in_grid]]) {
    
    // 边界检查：防止越界
    if (gid.x >= inputTexture.get_width() || gid.y >= inputTexture.get_height()) {
        return;
    }
    
    // 读取当前像素颜色
    float4 color = inputTexture.read(gid);
    
    // 判断是否为“内容”
    // 逻辑：透明度 > 0 且 不是纯白
    // 注意：Metal中的颜色是 0.0 ~ 1.0 的浮点数
    bool isTransparent = color.a < 0.01;
    bool isWhite = (color.r > 0.94 && color.g > 0.94 && color.b > 0.94);
    
    if (!isTransparent && !isWhite) {
        // 使用原子操作更新边界
        // memory_order_relaxed 性能最好，对于求极值足够安全
        atomic_fetch_min_explicit(&result.minX, gid.x, memory_order_relaxed);
        atomic_fetch_min_explicit(&result.minY, gid.y, memory_order_relaxed);
        atomic_fetch_max_explicit(&result.maxX, gid.x, memory_order_relaxed);
        atomic_fetch_max_explicit(&result.maxY, gid.y, memory_order_relaxed);
    }
}


// 帮助函数：计算亮度 (Luma)
float getLuma(float4 color) {
    return dot(color.rgb, float3(0.299, 0.587, 0.114));
}

// 内核函数：线条加粗 (形态学腐蚀 - 取局部最小值)
// radius: 加粗力度。1 = 轻微加粗(3x3范围), 2 = 明显加粗(5x5范围)
kernel void thickenBlackLines(texture2d<float, access::read> inTexture [[texture(0)]],
                              texture2d<float, access::write> outTexture [[texture(1)]],
                              constant int &radius [[buffer(0)]],
                              uint2 gid [[thread_position_in_grid]]) {
    
    // 边界检查
    if (gid.x >= inTexture.get_width() || gid.y >= inTexture.get_height()) {
        return;
    }
    
    // 初始化：我们要找“最黑”的颜色，所以初始值设为白色 (1.0)
    float4 darkestColor = float4(1.0, 1.0, 1.0, 1.0);
    float minLuma = 1.0;
    
    // 遍历周围的像素 (卷积核)
    // 比如 radius = 1，就遍历 x: -1~1, y: -1~1 (3x3格子)
    for (int j = -radius; j <= radius; j++) {
        for (int i = -radius; i <= radius; i++) {
            // 计算邻居坐标，防止越界
            int coordX = int(gid.x) + i;
            int coordY = int(gid.y) + j;
            
            // 简单的边界钳制
            coordX = max(0, min(coordX, int(inTexture.get_width() - 1)));
            coordY = max(0, min(coordY, int(inTexture.get_height() - 1)));
            
            // 读取邻居颜色
            float4 neighborColor = inTexture.read(uint2(coordX, coordY));
            
            // 计算邻居有多“黑”
            // 注意：如果你的图是透明背景，这里逻辑要微调，
            // 下面这个逻辑通用于：白底黑字 或 透底黑字(且alpha正确)
            
            float luma = getLuma(neighborColor);
            
            // 如果这是一个有效的黑色像素 (假设 Alpha > 0.1)
            // 只要邻居比当前记录的更黑，就采纳它
            if (neighborColor.a > 0.1 && luma < minLuma) {
                minLuma = luma;
                darkestColor = neighborColor;
            }
        }
    }
    
    // 将找到的最黑的颜色写入当前像素
    outTexture.write(darkestColor, gid);
}
