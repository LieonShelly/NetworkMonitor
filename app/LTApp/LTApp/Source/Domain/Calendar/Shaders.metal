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
    bool isWhite = (color.r > 0.8 && color.g > 0.8 && color.b > 0.8);
    
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
    if (minLuma > 0.95) {
        // 背景 -> 全透明
        outTexture.write(float4(0.0, 0.0, 0.0, 0.0), gid);
    } else {
        outTexture.write(float4(darkestColor.rgb, 1.0), gid);
    }
}


kernel void dilate_mask(texture2d<half, access::read> inMask [[texture(0)]],
                        texture2d<half, access::write> outMask [[texture(1)]],
                        constant int &radius [[buffer(0)]],
                        uint2 gid [[thread_position_in_grid]]) {
    
    if (gid.x >= outMask.get_width() || gid.y >= outMask.get_height()) { return; }

    int r = radius;
    if (r <= 0) {
        outMask.write(inMask.read(gid), gid);
        return;
    }

    int r2 = r * r;
    half isEffective = 0.0h;

    // 搜索周围的像素
    for (int j = -r; j <= r; j++) {
        for (int i = -r; i <= r; i++) {
            // 切割成完美的圆形内核
            if (i * i + j * j <= r2) {
                uint2 readPos = uint2(clamp(int(gid.x) + i, 0, int(inMask.get_width() - 1)),
                                      clamp(int(gid.y) + j, 0, int(inMask.get_height() - 1)));
                
                // 如果发现邻居是蒙版有效区域
                if (inMask.read(readPos).r > 0.5h) {
                    isEffective = 1.0h;
                    break; // 【性能核心】: 找到了就立刻停止搜索当前像素！
                }
            }
        }
        if (isEffective > 0.5h) break; // 只要变色了，外层循环也立刻停止！
    }

    // 写入膨胀后的单通道 Mask
    outMask.write(half4(isEffective, 0.0h, 0.0h, 1.0h), gid);
}


// ---------------------------------------------------------
// Pass 2: 颜色叠加着色器
// ---------------------------------------------------------
struct OverlayColor {
    float4 color; // r, g, b, a (刚好 16 字节)
};

kernel void apply_color_overlay(texture2d<half, access::read> inTexture [[texture(0)]],
                                texture2d<half, access::read> maskTexture [[texture(1)]], // 读取 Pass1 产物
                                texture2d<half, access::write> outTexture [[texture(2)]],
                                constant OverlayColor &params [[buffer(0)]],
                                uint2 gid [[thread_position_in_grid]]) {
                                
    if (gid.x >= inTexture.get_width() || gid.y >= inTexture.get_height()) { return; }

    half origAlpha = inTexture.read(gid).a;
    half maskValue = maskTexture.read(gid).r;

    half4 outColor;
    
    if (maskValue > 0.5h) {
        half finalAlpha;
        if (origAlpha > 0.0h && origAlpha < 1.0h) {
            finalAlpha = origAlpha;
        } else {
            finalAlpha = 1.0h;
        }
        
        outColor = half4(half(params.color.r), half(params.color.g), half(params.color.b), finalAlpha);
        
        if (origAlpha > 0.0h) {
            outColor = inTexture.read(gid);
        }
    } else {
        outColor = half4(0.0h, 0.0h, 0.0h, 0.0h);
    }

    outTexture.write(outColor, gid);
}
