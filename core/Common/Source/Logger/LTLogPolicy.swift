//
//  LTLogPolicy.swift
//  LTCommon
//
//  Created by Renjun Li on 2026/4/30.
//

import Foundation

public struct LTLogSamplingPolicy: Sendable, Equatable {
    public static let always = LTLogSamplingPolicy(rate: 1)
    public static let disabled = LTLogSamplingPolicy(rate: 0, alwaysRecordAtOrAbove: nil)

    public let rate: Double
    public let alwaysRecordAtOrAbove: LTLogLevel?

    public init(rate: Double, alwaysRecordAtOrAbove: LTLogLevel? = .error) {
        self.rate = min(max(rate, 0), 1)
        self.alwaysRecordAtOrAbove = alwaysRecordAtOrAbove
    }

    func shouldRecord(level: LTLogLevel) -> Bool {
        if let alwaysRecordAtOrAbove, level >= alwaysRecordAtOrAbove {
            return true
        }

        if rate >= 1 {
            return true
        }

        if rate <= 0 {
            return false
        }

        return Double.random(in: 0 ..< 1) < rate
    }
}

public struct LTLogRateLimitPolicy: Sendable, Equatable {
    public static let disabled = LTLogRateLimitPolicy(maxEvents: Int.max, interval: 1)

    public let maxEvents: Int
    public let interval: TimeInterval

    public init(maxEvents: Int, interval: TimeInterval) {
        self.maxEvents = max(0, maxEvents)
        self.interval = max(0, interval)
    }

    var isEnabled: Bool {
        maxEvents < Int.max && interval > 0
    }
}

final class LTLogRateLimiter: @unchecked Sendable {
    private let lock = NSRecursiveLock()
    private let policy: LTLogRateLimitPolicy
    private var timestamps: [Date] = []

    init(policy: LTLogRateLimitPolicy) {
        self.policy = policy
    }

    func allow(_ timestamp: Date) -> Bool {
        guard policy.isEnabled else {
            return true
        }

        lock.lock()
        defer { lock.unlock() }

        let oldestAllowed = timestamp.addingTimeInterval(-policy.interval)
        timestamps.removeAll { $0 < oldestAllowed }

        guard timestamps.count < policy.maxEvents else {
            return false
        }

        timestamps.append(timestamp)
        return true
    }
}
