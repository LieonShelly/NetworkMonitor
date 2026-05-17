//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
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
