//
//  SandboxProbe.swift
//  LTCommon
//
//  Created by Renjun Li on 2026/4/28.
//

import Darwin

/// 沙盒逃逸与越权检测：
///   1. 尝试向系统受限目录写入临时文件（+30 分）
///   2. 检查 /Applications 是否被篡改为软链接（+25 分）
@inline(__always)
func evaluateSandboxRisk() -> Int {
    var score = 0
    score += probeWriteAccess()
    score += probeSymbolicLink()
    return score
}


/// 尝试在 /private/ 下创建临时文件。
/// 正常沙盒环境中此操作必定失败；若成功则说明沙盒被攻破。
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

/// 使用 lstat() 检测 /Applications 是否为软链接。
/// 越狱设备上该目录常被重定向至越狱应用安装目录。
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
