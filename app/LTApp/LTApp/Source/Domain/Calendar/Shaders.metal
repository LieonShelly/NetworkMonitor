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
kernel void thickenBlackLines(texture2d<float, access::read> inTexture [[texture(0)]],
                              texture2d<float, access::write> outTexture [[texture(1)]],
                              constant int &radius [[buffer(0)]],
                              constant uint2 &cropOffset [[buffer(1)]], // 新增：偏移量
                              uint2 gid [[thread_position_in_grid]]) {
    
    // 1. 这里的 gid 是“输出纹理”（小图）的坐标
    // 如果超出了输出纹理的范围，直接退出
    if (gid.x >= outTexture.get_width() || gid.y >= outTexture.get_height()) {
        return;
    }
    
    // 2. 映射回“原图”（大图）的中心坐标
    // 所有的读取操作都要基于这个 originCoord
    int originX = int(gid.x) + int(cropOffset.x);
    int originY = int(gid.y) + int(cropOffset.y);
    
    float4 darkestColor = float4(1.0, 1.0, 1.0, 1.0);
    float minLuma = 1.0;
    
    // 3. 遍历邻居 (卷积)
    for (int j = -radius; j <= radius; j++) {
        for (int i = -radius; i <= radius; i++) {
            
            // 计算在原图中的绝对坐标
            int currentReadX = originX + i;
            int currentReadY = originY + j;
            
            // 边界保护：必须限制在【原图】的大小范围内
            currentReadX = max(0, min(currentReadX, int(inTexture.get_width() - 1)));
            currentReadY = max(0, min(currentReadY, int(inTexture.get_height() - 1)));
            
            float4 neighborColor = inTexture.read(uint2(currentReadX, currentReadY));
            float luma = getLuma(neighborColor);
            
            if (neighborColor.a > 0.1 && luma < minLuma) {
                minLuma = luma;
                darkestColor = neighborColor;
            }
        }
    }
    
    // 4. 写入输出纹理 (小图)
    outTexture.write(darkestColor, gid);
}
