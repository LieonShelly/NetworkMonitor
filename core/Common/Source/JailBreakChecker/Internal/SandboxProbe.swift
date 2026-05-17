//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Darwin

@inline(__always)
func evaluateSandboxRisk() -> Int {
    var score = 0
    score += probeWriteAccess()
    score += probeSymbolicLink()
    return score
}


@inline(__always)
private func probeWriteAccess() -> Int {
    // 探针文件路径："/private/lt_env_probe"
    let encryptedProbe: [UInt8] = [
        0x32, 0x30, 0x2B, 0x34, 0x23, 0x36, 0x27, 0x6D, 0x2E, 0x36, 0x1D, 0x27, 0x2C, 0x34, 0x1D, 0x32, 0x30, 0x2D, 0x20, 0x27
    ]
    var probePath = xorDecrypt(encryptedProbe, key: kXORKey)
    defer { eraseString(&probePath) }

    var result = 0
    probePath.withCString { cPath in
        // 以写模式打开，检测是否具备越权写入能力
        if let fp = fopen(cPath, "w+") {
            fclose(fp)
            remove(cPath)
            result = 30
        }
    }
    return result
}

@inline(__always)
private func probeSymbolicLink() -> Int {
    // "/Applications" XOR(0x42)
    let encryptedApps: [UInt8] = [
        0x6D, 0x03, 0x32, 0x32, 0x2E, 0x2B, 0x21, 0x23, 0x36, 0x2B, 0x2D, 0x2C, 0x31
    ]
    var appsPath = xorDecrypt(encryptedApps, key: kXORKey)
    defer { eraseString(&appsPath) }

    return appsPath.withCString { cPath -> Int in
        var st = Darwin.stat()
        guard Darwin.lstat(cPath, &st) == 0 else { return 0 }
        let isSymlink = (st.st_mode & S_IFMT) == S_IFLNK
        return isSymlink ? 25 : 0
    }
}
