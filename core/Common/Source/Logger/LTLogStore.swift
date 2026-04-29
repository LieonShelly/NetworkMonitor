//
//  LTLogStore.swift
//  LTCommon
//
//  Created by Renjun Li on 2026/4/29.
//

import Foundation

final class LTLogStore: @unchecked Sendable {
    static let shared = LTLogStore()

    private let lock = NSRecursiveLock()
    private var configuration = LTLogConfiguration()

    private init() { }

    func configure(_ configuration: LTLogConfiguration) {
        lock.lock()
        defer { lock.unlock() }
        self.configuration = configuration
    }

    func currentConfiguration() -> LTLogConfiguration {
        lock.lock()
        defer { lock.unlock() }
        return configuration
    }

    func setMinimumLevel(_ minimumLevel: LTLogLevel) {
        lock.lock()
        defer { lock.unlock() }
        configuration = LTLogConfiguration(
            subsystem: configuration.subsystem,
            minimumLevel: minimumLevel,
            environment: configuration.environment,
            sinks: configuration.sinks
        )
    }

    func addSink(_ sink: any LTLogSink) {
        lock.lock()
        defer { lock.unlock() }
        configuration = LTLogConfiguration(
            subsystem: configuration.subsystem,
            minimumLevel: configuration.minimumLevel,
            environment: configuration.environment,
            sinks: configuration.sinks + [sink]
        )
    }

    func removeAllSinks() {
        lock.lock()
        defer { lock.unlock() }
        configuration = LTLogConfiguration(
            subsystem: configuration.subsystem,
            minimumLevel: configuration.minimumLevel,
            environment: configuration.environment,
            sinks: []
        )
    }

    func isEnabled(_ level: LTLogLevel) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return level >= configuration.minimumLevel
    }

    func record(
        level: LTLogLevel,
        subsystem: String,
        category: String,
        file: StaticString,
        function: StaticString,
        line: UInt
    ) {
        let snapshot: (environment: LTLogEnvironment, sinks: [any LTLogSink])? = {
            lock.lock()
            defer { lock.unlock() }

            guard level >= configuration.minimumLevel else {
                return nil
            }

            return (configuration.environment, configuration.sinks)
        }()

        guard let snapshot, snapshot.sinks.isEmpty == false else {
            return
        }

        let event = LTLogEvent(
            level: level,
            subsystem: subsystem,
            category: category,
            environment: snapshot.environment,
            file: file.description,
            function: function.description,
            line: line
        )

        snapshot.sinks.forEach { sink in
            sink.log(event)
        }
    }
}
