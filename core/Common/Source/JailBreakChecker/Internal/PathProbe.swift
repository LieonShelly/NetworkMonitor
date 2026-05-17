//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Darwin
import MachO


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
