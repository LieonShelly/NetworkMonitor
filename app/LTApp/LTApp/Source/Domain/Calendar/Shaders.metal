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
// 增加了一个参数：cropOffset
// ... 之前的代码不变 ...

// 内核函数：线条加粗 + 去除背景
kernel void thickenAndRemoveBackground(texture2d<float, access::read> inTexture [[texture(0)]],
                                       texture2d<float, access::write> outTexture [[texture(1)]],
                                       constant int &radius [[buffer(0)]],
                                       constant uint2 &cropOffset [[buffer(1)]],
                                       uint2 gid [[thread_position_in_grid]]) {
    
    if (gid.x >= outTexture.get_width() || gid.y >= outTexture.get_height()) {
        return;
    }
    
    int originX = int(gid.x) + int(cropOffset.x);
    int originY = int(gid.y) + int(cropOffset.y);
    
    float4 darkestColor = float4(1.0, 1.0, 1.0, 1.0);
    float minLuma = 1.0;
    
    // 腐蚀寻找最黑像素
    for (int j = -radius; j <= radius; j++) {
        for (int i = -radius; i <= radius; i++) {
            int currentReadX = max(0, min(originX + i, int(inTexture.get_width() - 1)));
            int currentReadY = max(0, min(originY + j, int(inTexture.get_height() - 1)));
            
            float4 neighborColor = inTexture.read(uint2(currentReadX, currentReadY));
            float luma = getLuma(neighborColor);
            
            // 只要不是全透明，就参与比较
            if (neighborColor.a > 0.05 && luma < minLuma) {
                minLuma = luma;
                darkestColor = neighborColor;
            }
        }
    }
    
    // 去除背景逻辑
    // 建议使用 0.90 ~ 0.95，能容忍 JPEG 压缩带来的“不纯的白色”
    if (minLuma > 0.95) {
        // 背景 -> 全透明
        outTexture.write(float4(0.0, 0.0, 0.0, 0.0), gid);
    } else {
        // 内容 -> 保留原色
        // 强制 Alpha = 1.0 确保线条实心，或者使用 darkestColor.a 保留原透明度
        // 如果你的线条在黑色背景上看不清，可能是因为这里输出了半透明黑色
        // 这里我们强制它不透明：
        outTexture.write(float4(darkestColor.rgb, 1.0), gid);
    }
}
