//
//  URLSchemeProbe.swift
//  LTCommon
//
//  Created by Renjun Li on 2026/4/28.
//

import UIKit

// MARK: - URL Scheme Detection

/// 通过 canOpenURL 探测是否安装了越狱商店应用。
/// 每响应一个协议头累加 10 分。
///
/// ⚠️ 宿主 App 的 Info.plist 必须在 LSApplicationQueriesSchemes 中
///    声明 cydia、sileo、zbra，否则此检测恒返回 0。
/// ⚠️ 必须在主线程调用（UIApplication 限制）。
@inline(__always)
func evaluateURLSchemeRisk() -> Int {
    guard Thread.isMainThread else { return 0 }

    var score = 0
    for encryptedScheme in ObfuscatedURLScheme.all {
        var schemeStr = xorDecrypt(encryptedScheme, key: kXORKey)
        defer { eraseString(&schemeStr) }

        guard let url = URL(string: schemeStr) else { continue }
        if UIApplication.shared.canOpenURL(url) {
            score += 10
        }
    }
    return score
}
