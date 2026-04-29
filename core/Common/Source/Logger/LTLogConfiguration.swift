//
//  LTLogConfiguration.swift
//  LTCommon
//
//  Created by Renjun Li on 2026/4/29.
//

import Foundation

public enum LTLogEnvironment: String, Sendable {
    case debug
    case staging
    case production
}

public struct LTLogConfiguration: Sendable {
    public let subsystem: String
    public let minimumLevel: LTLogLevel
    public let environment: LTLogEnvironment
    public let sinks: [any LTLogSink]

    public init(
        subsystem: String = Bundle.main.bundleIdentifier ?? "com.little.things",
        minimumLevel: LTLogLevel = .info,
        environment: LTLogEnvironment = .production,
        sinks: [any LTLogSink] = []
    ) {
        self.subsystem = subsystem
        self.minimumLevel = minimumLevel
        self.environment = environment
        self.sinks = sinks
    }
}
