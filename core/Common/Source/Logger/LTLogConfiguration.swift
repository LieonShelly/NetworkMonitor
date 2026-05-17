//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation

public enum LTLogEnvironment: String, Codable, Sendable {
    case debug
    case staging
    case production
}

public struct LTLogConfiguration: Sendable {
    public let subsystem: String
    public let minimumLevel: LTLogLevel
    public let environment: LTLogEnvironment
    public let sinks: [any LTLogSink]
    public let breadcrumbConfiguration: LTBreadcrumbConfiguration
    public let samplingPolicy: LTLogSamplingPolicy
    public let rateLimitPolicy: LTLogRateLimitPolicy

    public init(
        subsystem: String = Bundle.main.bundleIdentifier ?? "com.little.things",
        minimumLevel: LTLogLevel = .info,
        environment: LTLogEnvironment = .production,
        sinks: [any LTLogSink] = [],
        breadcrumbConfiguration: LTBreadcrumbConfiguration = .init(),
        samplingPolicy: LTLogSamplingPolicy = .always,
        rateLimitPolicy: LTLogRateLimitPolicy = .disabled
    ) {
        self.subsystem = subsystem
        self.minimumLevel = minimumLevel
        self.environment = environment
        self.sinks = sinks
        self.breadcrumbConfiguration = breadcrumbConfiguration
        self.samplingPolicy = samplingPolicy
        self.rateLimitPolicy = rateLimitPolicy
    }
}
