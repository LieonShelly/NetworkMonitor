//
//  DylibProbe.swift
//  LTCommon
//
//  Created by Renjun Li on 2026/4/28.
//

import MachO

// MARK: - Injected Dylib Detection

/// 遍历当前进程加载的所有动态库，检测是否存在越狱注入插件。
/// 每命中一个可疑库累加 20 分。
@inline(__always)
func evaluateDylibRisk() -> Int {
    var score = 0
    let imageCount = _dyld_image_count()

    // 预先解密所有敏感关键词，循环结束后统一清理
    var keywords: [String] = ObfuscatedDylibKeyword.all.map {
        xorDecrypt($0, key: kXORKey)
    }
    defer {
        for i in keywords.indices {
            eraseString(&keywords[i])
        }
    }

    for i in 0 ..< imageCount {
        guard let rawName = _dyld_get_image_name(i) else { continue }
        // 转换为 Swift String 并统一小写，便于大小写不敏感比对
        let imageName = String(cString: rawName).lowercased()
        for keyword in keywords where imageName.contains(keyword) {
            score += 20
            break   // 同一个库命中多个关键词只计一次
        }
    }

    return score
}
