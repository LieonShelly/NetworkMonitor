//
//  LTBCrashCapture.swift
//  LTCommon
//
//  Created by Codex on 2026/5/5.
//

import Darwin
import Foundation

enum LTBCrashCapture {
    nonisolated(unsafe)
    private static var store: LTBCrashReportStore?
    nonisolated(unsafe)
    private static var previousExceptionHandler: NSUncaughtExceptionHandler?

    static func install(store: LTBCrashReportStore) {
        self.store = store

        previousExceptionHandler = NSGetUncaughtExceptionHandler()
        NSSetUncaughtExceptionHandler(handleException)
        LTBCrashSignalBridge.installSignalHandlers(directoryPath: store.directoryPath)
    }

    private static let handleException: @convention(c) (NSException) -> Void = { exception in
        let report = LTBCrashReportBuilder.makeNSExceptionReport(
            name: exception.name.rawValue,
            reason: exception.reason ?? "unknown",
            callStackSymbols: exception.callStackSymbols
        )
        store?.save(report)
        previousExceptionHandler?(exception)
    }
}
