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
    let record: @Sendable (LTLogLevel, String?, LTLogMetadata, StaticString, StaticString, UInt) -> Void

    init(subsystem: String, category: String) {
        self.subsystem = subsystem
        self.category = category

        let osLogger = Logger(subsystem: subsystem, category: category)
        self.logger = { level in
            LTLogStore.shared.isEnabled(level) ? osLogger : .disabled
        }
        self.record = { level, message, metadata, file, function, line in
            LTLogStore.shared.record(
                level: level,
                subsystem: subsystem,
                category: category,
                message: message,
                metadata: metadata,
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
        record(.trace, nil, [:], file, function, line)
        logger(.trace).trace(message)
    }

    @_transparent @_optimize(none) @_semantics("oslog.requires_constant_arguments")
    public func debug(
        _ message: OSLogMessage,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        record(.debug, nil, [:], file, function, line)
        logger(.debug).debug(message)
    }

    @_transparent @_optimize(none) @_semantics("oslog.requires_constant_arguments")
    public func info(
        _ message: OSLogMessage,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        record(.info, nil, [:], file, function, line)
        logger(.info).info(message)
    }

    @_transparent @_optimize(none) @_semantics("oslog.requires_constant_arguments")
    public func notice(
        _ message: OSLogMessage,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        record(.notice, nil, [:], file, function, line)
        logger(.notice).notice(message)
    }

    @_transparent @_optimize(none) @_semantics("oslog.requires_constant_arguments")
    public func warning(
        _ message: OSLogMessage,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        record(.warning, nil, [:], file, function, line)
        logger(.warning).warning(message)
    }

    @_transparent @_optimize(none) @_semantics("oslog.requires_constant_arguments")
    public func error(
        _ message: OSLogMessage,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        record(.error, nil, [:], file, function, line)
        logger(.error).error(message)
    }

    @_transparent @_optimize(none) @_semantics("oslog.requires_constant_arguments")
    public func fault(
        _ message: OSLogMessage,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        record(.fault, nil, [:], file, function, line)
        logger(.fault).fault(message)
    }

    public func trace(
        public message: @autoclosure () -> String,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        logPublic(level: .trace, message: message, file: file, function: function, line: line)
    }

    public func debug(
        public message: @autoclosure () -> String,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        logPublic(level: .debug, message: message, file: file, function: function, line: line)
    }

    public func info(
        public message: @autoclosure () -> String,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        logPublic(level: .info, message: message, file: file, function: function, line: line)
    }

    public func notice(
        public message: @autoclosure () -> String,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        logPublic(level: .notice, message: message, file: file, function: function, line: line)
    }

    public func warning(
        public message: @autoclosure () -> String,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        logPublic(level: .warning, message: message, file: file, function: function, line: line)
    }

    public func error(
        public message: @autoclosure () -> String,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        logPublic(level: .error, message: message, file: file, function: function, line: line)
    }

    public func fault(
        public message: @autoclosure () -> String,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        logPublic(level: .fault, message: message, file: file, function: function, line: line)
    }

    public func trace(
        exportable message: @autoclosure () -> String,
        metadata: LTLogMetadata = [:],
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        logExportable(level: .trace, message: message(), metadata: metadata, file: file, function: function, line: line)
    }

    public func debug(
        exportable message: @autoclosure () -> String,
        metadata: LTLogMetadata = [:],
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        logExportable(level: .debug, message: message(), metadata: metadata, file: file, function: function, line: line)
    }

    public func info(
        exportable message: @autoclosure () -> String,
        metadata: LTLogMetadata = [:],
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        logExportable(level: .info, message: message(), metadata: metadata, file: file, function: function, line: line)
    }

    public func notice(
        exportable message: @autoclosure () -> String,
        metadata: LTLogMetadata = [:],
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        logExportable(level: .notice, message: message(), metadata: metadata, file: file, function: function, line: line)
    }

    public func warning(
        exportable message: @autoclosure () -> String,
        metadata: LTLogMetadata = [:],
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        logExportable(level: .warning, message: message(), metadata: metadata, file: file, function: function, line: line)
    }

    public func error(
        exportable message: @autoclosure () -> String,
        metadata: LTLogMetadata = [:],
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        logExportable(level: .error, message: message(), metadata: metadata, file: file, function: function, line: line)
    }

    public func fault(
        exportable message: @autoclosure () -> String,
        metadata: LTLogMetadata = [:],
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        logExportable(level: .fault, message: message(), metadata: metadata, file: file, function: function, line: line)
    }

    private func logPublic(
        level: LTLogLevel,
        message: () -> String,
        file: StaticString,
        function: StaticString,
        line: UInt
    ) {
        guard LTLogStore.shared.isEnabled(level) else {
            return
        }

        let publicMessage = message()
        logger(level).log(level: level.osLogType, "\(publicMessage, privacy: .public)")
        record(level, nil, [:], file, function, line)
    }

    private func logExportable(
        level: LTLogLevel,
        message: String,
        metadata: LTLogMetadata,
        file: StaticString,
        function: StaticString,
        line: UInt
    ) {
        guard LTLogStore.shared.isEnabled(level) else {
            return
        }

        logger(level).log(level: level.osLogType, "\(message, privacy: .public)")
        record(level, message, metadata, file, function, line)
    }
}
