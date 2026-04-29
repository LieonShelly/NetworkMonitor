//
//  LTTestLogSink.swift
//  LTCommon
//
//  Created by Renjun Li on 2026/4/29.
//

import Foundation

public final class LTTestLogSink: LTLogSink, @unchecked Sendable {
    private let lock = NSRecursiveLock()
    private var recordedEvents: [LTLogEvent] = []

    public init() { }

    public var events: [LTLogEvent] {
        lock.lock()
        defer { lock.unlock() }
        return recordedEvents
    }

    public func log(_ event: LTLogEvent) {
        lock.lock()
        defer { lock.unlock() }
        recordedEvents.append(event)
    }

    public func removeAll() {
        lock.lock()
        defer { lock.unlock() }
        recordedEvents.removeAll()
    }
}
