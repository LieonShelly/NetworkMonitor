//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation

public typealias LTLogMetadata = [String: String]

public struct LTLogEvent: Codable, Sendable, Equatable {
    public let level: LTLogLevel
    public let subsystem: String
    public let category: String
    public let environment: LTLogEnvironment
    public let timestamp: Date
    public let message: String?
    public let metadata: LTLogMetadata
    public let file: String
    public let function: String
    public let line: UInt

    public init(
        level: LTLogLevel,
        subsystem: String,
        category: String,
        environment: LTLogEnvironment,
        timestamp: Date = Date(),
        message: String? = nil,
        metadata: LTLogMetadata = [:],
        file: String,
        function: String,
        line: UInt
    ) {
        self.level = level
        self.subsystem = subsystem
        self.category = category
        self.environment = environment
        self.timestamp = timestamp
        self.message = message
        self.metadata = metadata
        self.file = file
        self.function = function
        self.line = line
    }
}
