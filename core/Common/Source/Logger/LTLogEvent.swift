//
//  LTLogEvent.swift
//  LTCommon
//
//  Created by Renjun Li on 2026/4/29.
//

import Foundation

public struct LTLogEvent: Sendable, Equatable {
    public let level: LTLogLevel
    public let subsystem: String
    public let category: String
    public let environment: LTLogEnvironment
    public let timestamp: Date
    public let file: String
    public let function: String
    public let line: UInt

    public init(
        level: LTLogLevel,
        subsystem: String,
        category: String,
        environment: LTLogEnvironment,
        timestamp: Date = Date(),
        file: String,
        function: String,
        line: UInt
    ) {
        self.level = level
        self.subsystem = subsystem
        self.category = category
        self.environment = environment
        self.timestamp = timestamp
        self.file = file
        self.function = function
        self.line = line
    }
}
