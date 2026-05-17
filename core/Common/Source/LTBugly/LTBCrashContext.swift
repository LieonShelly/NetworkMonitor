//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation

enum LTBCrashContext {
    struct RuntimeSnapshot {
        let app: LTBCrashReport.App
        let device: LTBCrashReport.Device
    }

    static func runtime() -> RuntimeSnapshot {
        .init(
            app: .init(
                bundleID: Bundle.main.bundleIdentifier ?? "unknown",
                version: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "unknown",
                build: Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "unknown"
            ),
            device: .init(
                model: deviceModel(),
                os: "iOS \(ProcessInfo.processInfo.operatingSystemVersionString)"
            )
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
