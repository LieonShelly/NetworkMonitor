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


struct OverlayColor {
    float4 color;
};


kernel void apply_color_overlay(texture2d<half, access::read> inTexture [[texture(0)]],
                                texture2d<half, access::read> maskTexture [[texture(1)]],
                                texture2d<half, access::write> outTexture [[texture(2)]],
                                constant OverlayColor &overlayColor [[buffer(0)]],
                                uint2 gid [[thread_position_in_grid]]) {
                                
    if (gid.x >= inTexture.get_width() || gid.y >= inTexture.get_height()) {
        return;
    }

    // 读取原始像素的 Alpha 和 蒙版的标识
    half origAlpha = inTexture.read(gid).a;
    // maskTexture 是单通道纹理，用 .r 读取
    half maskValue = maskTexture.read(gid).r;

    half4 outColor;
    
    // maskValue > 0.5 说明在连通域内部（包括图形实体和被包裹的镂空区域）
    if (maskValue > 0.5h) {
        half finalAlpha;
        
        // 【抗锯齿处理】: 如果原图 alpha 在 0~1 之间，说明是图形的平滑边缘，保留原 alpha。
        // （因为泛洪算法遇到 alpha > 0 就会停止，所以边缘像素的 maskValue 一定是 1）
        if (origAlpha > 0.0h && origAlpha < 1.0h) {
            finalAlpha = origAlpha;
        } else {
            // 如果 origAlpha == 0 (内部镂空孔洞) 或 origAlpha == 1 (内部实心)，填满实色
            finalAlpha = 1.0h;
        }

        // 应用用户选择的颜色，结合计算出的 Alpha
        outColor = half4(half(overlayColor.color.r),
                         half(overlayColor.color.g),
                         half(overlayColor.color.b),
                         finalAlpha);
    } else {
        // 外部背景，完全透明
        outColor = half4(0.0h, 0.0h, 0.0h, 0.0h);
    }

    outTexture.write(outColor, gid);
}
