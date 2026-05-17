//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation

final class LTLogStore: @unchecked Sendable {
    static let shared = LTLogStore()

    private let lock = NSRecursiveLock()
    private var configuration = LTLogConfiguration()
    private var rateLimiter = LTLogRateLimiter(policy: .disabled)

    private init() { }

    func configure(_ configuration: LTLogConfiguration) {
        lock.lock()
        defer { lock.unlock() }
        self.configuration = configuration
        rateLimiter = LTLogRateLimiter(policy: configuration.rateLimitPolicy)
        LTBreadcrumbStore.shared.configure(configuration.breadcrumbConfiguration)
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
            sinks: configuration.sinks,
            breadcrumbConfiguration: configuration.breadcrumbConfiguration,
            samplingPolicy: configuration.samplingPolicy,
            rateLimitPolicy: configuration.rateLimitPolicy
        )
    }

    func addSink(_ sink: any LTLogSink) {
        lock.lock()
        defer { lock.unlock() }
        configuration = LTLogConfiguration(
            subsystem: configuration.subsystem,
            minimumLevel: configuration.minimumLevel,
            environment: configuration.environment,
            sinks: configuration.sinks + [sink],
            breadcrumbConfiguration: configuration.breadcrumbConfiguration,
            samplingPolicy: configuration.samplingPolicy,
            rateLimitPolicy: configuration.rateLimitPolicy
        )
    }

    func removeAllSinks() {
        lock.lock()
        defer { lock.unlock() }
        configuration = LTLogConfiguration(
            subsystem: configuration.subsystem,
            minimumLevel: configuration.minimumLevel,
            environment: configuration.environment,
            sinks: [],
            breadcrumbConfiguration: configuration.breadcrumbConfiguration,
            samplingPolicy: configuration.samplingPolicy,
            rateLimitPolicy: configuration.rateLimitPolicy
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
        message: String? = nil,
        metadata: LTLogMetadata = [:],
        file: StaticString,
        function: StaticString,
        line: UInt
    ) {
        let snapshot: (
            environment: LTLogEnvironment,
            sinks: [any LTLogSink],
            breadcrumbConfiguration: LTBreadcrumbConfiguration,
            samplingPolicy: LTLogSamplingPolicy,
            rateLimiter: LTLogRateLimiter
        )? = {
            lock.lock()
            defer { lock.unlock() }

            guard level >= configuration.minimumLevel else {
                return nil
            }

            return (
                configuration.environment,
                configuration.sinks,
                configuration.breadcrumbConfiguration,
                configuration.samplingPolicy,
                rateLimiter
            )
        }()

        guard let snapshot else {
            return
        }

        let event = LTLogEvent(
            level: level,
            subsystem: subsystem,
            category: category,
            environment: snapshot.environment,
            message: message,
            metadata: metadata,
            file: file.description,
            function: function.description,
            line: line
        )

        if snapshot.breadcrumbConfiguration.shouldRecord(level: level) {
            LTBreadcrumbStore.shared.record(event)
        }

        guard snapshot.sinks.isEmpty == false,
              snapshot.samplingPolicy.shouldRecord(level: level),
              snapshot.rateLimiter.allow(event.timestamp)
        else {
            return
        }

        snapshot.sinks.forEach { sink in
            sink.log(event)
        }
    }

    func fileLogSinks() -> [LTFileLogSink] {
        lock.lock()
        defer { lock.unlock() }
        return configuration.sinks.compactMap { $0 as? LTFileLogSink }
    }
}
