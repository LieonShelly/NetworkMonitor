//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Darwin
import UIKit



public final class EnvironmentConfig {

    // MARK: - Internal State

    /// 内存中保存的加密暗记号。
    /// 仅在 checkDeviceIntegrity() 调用后有效。
    nonisolated(unsafe) private static var cachedToken: String = ""

    /// 当前评估是否已完成。
    nonisolated(unsafe) private static var isEvaluated: Bool = false

    // MARK: - Public Interface

    /// 触发完整的设备环境检测流程，生成并缓存暗记号。
    /// 建议在 App 启动时调用一次。
    /// - Note: 重复调用会重新评估并刷新 Token。
    public static func checkDeviceIntegrity() {
        let score = computeRiskScore()
        cachedToken = buildToken(score: score)
        isEvaluated = true
    }

    /// 读取当前设备环境完整性的暗记号（只读）。
    ///
    /// Token 格式（Base64 编码）：`score|timestamp|signature`
    /// - 若尚未调用 `checkDeviceIntegrity()`，返回空字符串。
    public static var deviceIntegrityToken: String {
        guard isEvaluated else { return "" }
        return cachedToken
    }

    // MARK: - Private: Risk Aggregation

    /// 汇总所有探测模块的风险分值。
    private static func computeRiskScore() -> Int {
        var total = 0

        // 模块一-1：越狱文件路径嗅探
        total += evaluateFileSystemRisk()

        // 模块一-2：沙盒逃逸检测
        total += evaluateSandboxRisk()

        // 模块一-3：非法动态库监控
        total += evaluateDylibRisk()

        // 模块一-4：URL Scheme 探针（主线程）
        if Thread.isMainThread {
            total += evaluateURLSchemeRisk()
        }

        // 模块二-2：反调试安装 + 跟踪状态检测
        total += installAntiDebugAndEvaluate()
        
        generateObfuscatedBytes(for: "/Applications")

        return total
    }

    // MARK: - Private: Token Generation

    /// 将风险分值编码为加密暗记号。
    ///
    /// 结构：`{score}|{timestamp}|{xorSignature}`
    /// 整体进行 Base64 编码后作为最终 Token。
    private static func buildToken(score: Int) -> String {
        let timestamp = UInt64(Date().timeIntervalSince1970)
        let signature = buildSignature(score: score, timestamp: timestamp)
        let raw = "\(score)|\(timestamp)|\(signature)"
        // 转为 UTF-8 字节后 Base64 编码
        let data = Data(raw.utf8)
        return data.base64EncodedString()
    }

    /// 生成基于 XOR 的简单签名，防止 Token 被业务层篡改或伪造低分值。
    /// 签名 = (score XOR timestamp低16位) XOR kXORKey
    private static func buildSignature(score: Int, timestamp: UInt64) -> String {
        let timeLow = UInt16(timestamp & 0xFFFF)
        let rawSig = (UInt16(score & 0xFFFF) ^ timeLow) ^ UInt16(kXORKey)
        return String(format: "%04X", rawSig)
    }
}


extension EnvironmentConfig {

    /// 解析 Token 中的风险分值（供调试/测试使用，勿暴露给业务层）。
    static func parseScore(from token: String) -> Int? {
        guard
            let data = Data(base64Encoded: token),
            let raw = String(data: data, encoding: .utf8)
        else { return nil }
        let parts = raw.split(separator: "|")
        guard parts.count >= 1, let score = Int(parts[0]) else { return nil }
        return score
    }

    /// 高风险阈值（≥ 60 分视为高危环境）。
    static let highRiskThreshold: Int = 60
}
