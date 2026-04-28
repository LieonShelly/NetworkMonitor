//
//  PathProbe.swift
//  LTCommon
//
//  Created by Renjun Li on 2026/4/28.
//

import Darwin
import MachO

// MARK: - Jailbreak Path Detection

/// 使用底层 C API（stat / access）嗅探越狱特征路径。
/// 严禁使用 FileManager 等高级 Foundation API。
/// 每命中一条路径累加 15 分。
@inline(__always)
func evaluateFileSystemRisk() -> Int {
    var score = 0
    let paths = ObfuscatedPath.all

    for encryptedPath in paths {
        var decrypted = xorDecrypt(encryptedPath, key: kXORKey)
        defer { eraseString(&decrypted) }

        score += decrypted.withCString { cPath -> Int in
            // 优先使用 stat()：检测路径是否存在（含软链接目标）
            var st = stat()
            let statRet: Int32 = stat(cPath, &st)
            if statRet == 0 {
                return 15
            }
            // 备用 access()：检测可访问性（F_OK = 存在性校验）
            let accessRet: Int32 = access(cPath, F_OK)
            if accessRet == 0 {
                return 15
            }
            return 0
        }
    }

    return score
}
