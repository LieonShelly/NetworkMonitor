//
//  LTBCrashContext.swift
//  LTCommon
//
//  Created by Codex on 2026/5/5.
//

import Foundation

enum LTBCrashContext {
    static func makeReport(
        exceptionType: String,
        name: String,
        reason: String,
        callStackSymbols: [String] = Thread.callStackSymbols
    ) -> LTBCrashReport {
        LTBCrashReport(
            crashID: UUID().uuidString,
            timestamp: Date().timeIntervalSince1970,
            app: .init(
                bundleID: Bundle.main.bundleIdentifier ?? "unknown",
                version: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "unknown",
                build: Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "unknown"
            ),
            device: .init(
                model: deviceModel(),
                os: "iOS \(ProcessInfo.processInfo.operatingSystemVersionString)"
            ),
            exception: .init(
                type: exceptionType,
                name: name,
                reason: reason
            ),
            threads: [
                .init(crashed: true, frames: callStackSymbols)
            ],
            binaryImages: []
        )
    }

    private static func deviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)

        return withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingCString: $0) ?? "unknown"
            }
        }
    }
}
