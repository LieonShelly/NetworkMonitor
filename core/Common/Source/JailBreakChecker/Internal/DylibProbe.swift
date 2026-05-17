//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import MachO


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
        print(imageName)
        for keyword in keywords where imageName.contains(keyword) {
            score += 20
            break   // 同一个库命中多个关键词只计一次
        }
    }

    return score
}
