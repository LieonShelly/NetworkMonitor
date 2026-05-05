//
//  LTBCrashSignalBridge.swift
//  LTCommon
//
//  Created by Codex on 2026/5/5.
//

import Foundation

@_silgen_name("ltbugly_install_signal_handlers")
private func ltbugly_install_signal_handlers(_ directoryPath: UnsafePointer<CChar>?) -> Void

@_silgen_name("ltbugly_update_signal_report_context")
private func ltbugly_update_signal_report_context(_ contextJSON: UnsafePointer<CChar>?) -> Void

enum LTBCrashSignalBridge {
    static func installSignalHandlers(directoryPath: String) {
        directoryPath.withCString { pointer in
            ltbugly_install_signal_handlers(pointer)
        }
    }

    static func updateContext(_ payload: LTBCrashSignalContextPayload) {
        guard let data = try? JSONEncoder().encode(payload),
              let json = String(data: data, encoding: .utf8)
        else {
            return
        }

        json.withCString { pointer in
            ltbugly_update_signal_report_context(pointer)
        }
    }
}
