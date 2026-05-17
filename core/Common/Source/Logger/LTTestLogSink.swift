//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
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
