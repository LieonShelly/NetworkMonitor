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
    let logger: Logger

    @usableFromInline
    let record: @Sendable (LTLogLevel, String?, LTLogMetadata, StaticString, StaticString, UInt) -> Void

    @usableFromInline
    let isEnabled: @Sendable (LTLogLevel) -> Bool

    init(subsystem: String, category: String) {
        self.subsystem = subsystem
        self.category = category

        let osLogger = Logger(subsystem: subsystem, category: category)
        self.logger = osLogger
        self.isEnabled = { level in
            LTLogStore.shared.isEnabled(level)
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
        guard isEnabled(.trace) else {
            return
        }

        record(.trace, nil, [:], file, function, line)
        logger.trace(message)
    }

    @_transparent @_optimize(none) @_semantics("oslog.requires_constant_arguments")
    public func debug(
        _ message: OSLogMessage,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        guard isEnabled(.debug) else {
            return
        }

        record(.debug, nil, [:], file, function, line)
        logger.debug(message)
    }

    @_transparent @_optimize(none) @_semantics("oslog.requires_constant_arguments")
    public func info(
        _ message: OSLogMessage,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        guard isEnabled(.info) else {
            return
        }

        record(.info, nil, [:], file, function, line)
        logger.info(message)
    }

    @_transparent @_optimize(none) @_semantics("oslog.requires_constant_arguments")
    public func notice(
        _ message: OSLogMessage,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        guard isEnabled(.notice) else {
            return
        }

        record(.notice, nil, [:], file, function, line)
        logger.notice(message)
    }

    @_transparent @_optimize(none) @_semantics("oslog.requires_constant_arguments")
    public func warning(
        _ message: OSLogMessage,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        guard isEnabled(.warning) else {
            return
        }

        record(.warning, nil, [:], file, function, line)
        logger.warning(message)
    }

    @_transparent @_optimize(none) @_semantics("oslog.requires_constant_arguments")
    public func error(
        _ message: OSLogMessage,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        guard isEnabled(.error) else {
            return
        }

        record(.error, nil, [:], file, function, line)
        logger.error(message)
    }

    @_transparent @_optimize(none) @_semantics("oslog.requires_constant_arguments")
    public func fault(
        _ message: OSLogMessage,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        guard isEnabled(.fault) else {
            return
        }

        record(.fault, nil, [:], file, function, line)
        logger.fault(message)
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
        logger.log(level: level.osLogType, "\(publicMessage, privacy: .public)")
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

        logger.log(level: level.osLogType, "\(message, privacy: .public)")
        record(level, message, metadata, file, function, line)
    }
}
