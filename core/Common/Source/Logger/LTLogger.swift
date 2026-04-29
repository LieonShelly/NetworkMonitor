//
//  LTLogger.swift
//  LTCommon
//
//  Created by Renjun Li on 2026/4/29.
//

import OSLog

public struct LTLogger: Sendable {
    public let subsystem: String
    public let category: String

    @usableFromInline
    let logger: @Sendable (LTLogLevel) -> Logger

    @usableFromInline
    let record: @Sendable (LTLogLevel, StaticString, StaticString, UInt) -> Void

    init(subsystem: String, category: String) {
        self.subsystem = subsystem
        self.category = category

        let osLogger = Logger(subsystem: subsystem, category: category)
        self.logger = { level in
            LTLogStore.shared.isEnabled(level) ? osLogger : .disabled
        }
        self.record = { level, file, function, line in
            LTLogStore.shared.record(
                level: level,
                subsystem: subsystem,
                category: category,
                file: file,
                function: function,
                line: line
            )
        }
    }

    @_transparent @_optimize(none) @_semantics("oslog.requires_constant_arguments")
    public func trace(
        _ message: OSLogMessage,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        record(.trace, file, function, line)
        logger(.trace).trace(message)
    }

    @_transparent @_optimize(none) @_semantics("oslog.requires_constant_arguments")
    public func debug(
        _ message: OSLogMessage,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        record(.debug, file, function, line)
        logger(.debug).debug(message)
    }

    @_transparent @_optimize(none) @_semantics("oslog.requires_constant_arguments")
    public func info(
        _ message: OSLogMessage,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        record(.info, file, function, line)
        logger(.info).info(message)
    }

    @_transparent @_optimize(none) @_semantics("oslog.requires_constant_arguments")
    public func notice(
        _ message: OSLogMessage,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        record(.notice, file, function, line)
        logger(.notice).notice(message)
    }

    @_transparent @_optimize(none) @_semantics("oslog.requires_constant_arguments")
    public func warning(
        _ message: OSLogMessage,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        record(.warning, file, function, line)
        logger(.warning).warning(message)
    }

    @_transparent @_optimize(none) @_semantics("oslog.requires_constant_arguments")
    public func error(
        _ message: OSLogMessage,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        record(.error, file, function, line)
        logger(.error).error(message)
    }

    @_transparent @_optimize(none) @_semantics("oslog.requires_constant_arguments")
    public func fault(
        _ message: OSLogMessage,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        record(.fault, file, function, line)
        logger(.fault).fault(message)
    }
}
