//
//  BoundingBox.swift
//  LTApp
//
//  Created by Renjun Li on 2025/12/3.
//


#include <metal_stdlib>
using namespace metal;

struct BoundingBox {
    atomic_uint minX;
    atomic_uint minY;
    atomic_uint maxX;
    atomic_uint maxY;
};

kernel void detectContentBounds(texture2d<float, access::read> inputTexture [[texture(0)]],
                                device BoundingBox &result [[buffer(0)]],
                                uint2 gid [[thread_position_in_grid]]) {
    if (gid.x >= inputTexture.get_width() || gid.y >= inputTexture.get_height()) {
        return;
    }

    float4 color = inputTexture.read(gid);
    bool isTransparent = color.a < 0.01;
    bool isWhite = (color.r > 0.94 && color.g > 0.94 && color.b > 0.94);
    
    if (!isTransparent && !isWhite) {
        atomic_fetch_min_explicit(&result.minX, gid.x, memory_order_relaxed);
        atomic_fetch_min_explicit(&result.minY, gid.y, memory_order_relaxed);
        atomic_fetch_max_explicit(&result.maxX, gid.x, memory_order_relaxed);
        atomic_fetch_max_explicit(&result.maxY, gid.y, memory_order_relaxed);
    }
}


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
            int coordX = int(gid.x) + i;
            int coordY = int(gid.y) + j;
            
            coordX = max(0, min(coordX, int(inTexture.get_width() - 1)));
            coordY = max(0, min(coordY, int(inTexture.get_height() - 1)));
            
            // 读取邻居颜色
            float4 neighborColor = inTexture.read(uint2(coordX, coordY));
            
            // 计算邻居有多“黑”
            float luma = getLuma(neighborColor);
            
            if (neighborColor.a > 0.1 && luma < minLuma) {
                minLuma = luma;
                darkestColor = neighborColor;
            }
        }
    }
    outTexture.write(darkestColor, gid);
}
