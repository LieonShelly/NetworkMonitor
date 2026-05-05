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
    nonisolated(unsafe)
    private static var previousSignalHandlers: [Int32: sig_t] = [:]

    static func install(store: LTBCrashReportStore) {
        self.store = store

        previousExceptionHandler = NSGetUncaughtExceptionHandler()
        NSSetUncaughtExceptionHandler(handleException)

        [SIGABRT, SIGSEGV, SIGBUS, SIGILL, SIGFPE].forEach { signalType in
            previousSignalHandlers[signalType] = signal(signalType, handleSignal)
        }
    }

    private static let handleException: @convention(c) (NSException) -> Void = { exception in
        let report = LTBCrashContext.makeReport(
            exceptionType: "NSException",
            name: exception.name.rawValue,
            reason: exception.reason ?? "unknown",
            callStackSymbols: exception.callStackSymbols
        )
        store?.save(report)
        previousExceptionHandler?(exception)
    }

    private static let handleSignal: @convention(c) (Int32) -> Void = { signalType in
        let signalName = name(for: signalType)
        let report = LTBCrashContext.makeReport(
            exceptionType: signalName,
            name: signalName,
            reason: reason(for: signalType)
        )
        store?.save(report)

        signal(signalType, SIG_DFL)
        raise(signalType)
    }

    private static func name(for signalType: Int32) -> String {
        switch signalType {
        case SIGABRT:
            return "SIGABRT"
        case SIGSEGV:
            return "SIGSEGV"
        case SIGBUS:
            return "SIGBUS"
        case SIGILL:
            return "SIGILL"
        case SIGFPE:
            return "SIGFPE"
        default:
            return "SIG\(signalType)"
        }
    }

    private static func reason(for signalType: Int32) -> String {
        switch signalType {
        case SIGABRT:
            return "abort signal"
        case SIGSEGV:
            return "invalid memory access"
        case SIGBUS:
            return "bus error"
        case SIGILL:
            return "illegal instruction"
        case SIGFPE:
            return "floating point exception"
        default:
            return "unknown signal"
        }
    }
}
