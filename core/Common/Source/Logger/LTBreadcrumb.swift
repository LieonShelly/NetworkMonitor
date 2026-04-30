//
//  LTBreadcrumb.swift
//  LTCommon
//
//  Created by Renjun Li on 2026/4/30.
//

import Foundation

public struct LTBreadcrumbConfiguration: Sendable, Equatable {
    public let isEnabled: Bool
    public let capacity: Int
    public let minimumLevel: LTLogLevel

    public init(
        isEnabled: Bool = true,
        capacity: Int = 100,
        minimumLevel: LTLogLevel = .notice
    ) {
        self.isEnabled = isEnabled
        self.capacity = max(0, capacity)
        self.minimumLevel = minimumLevel
    }

    func shouldRecord(level: LTLogLevel) -> Bool {
        isEnabled && capacity > 0 && level >= minimumLevel
    }
}

public struct LTBreadcrumb: Codable, Sendable, Equatable {
    public let level: LTLogLevel
    public let category: String
    public let timestamp: Date
    public let message: String?
    public let metadata: LTLogMetadata
    public let file: String
    public let function: String
    public let line: UInt

    init(event: LTLogEvent) {
        self.level = event.level
        self.category = event.category
        self.timestamp = event.timestamp
        self.message = event.message
        self.metadata = event.metadata
        self.file = event.file
        self.function = event.function
        self.line = event.line
    }
}

final class LTBreadcrumbStore: @unchecked Sendable {
    static let shared = LTBreadcrumbStore()

    private let lock = NSRecursiveLock()
    private var configuration = LTBreadcrumbConfiguration()
    private var storage: [LTBreadcrumb] = []

    private init() { }

    var breadcrumbs: [LTBreadcrumb] {
        lock.lock()
        defer { lock.unlock() }
        return storage
    }

    func configure(_ configuration: LTBreadcrumbConfiguration) {
        lock.lock()
        defer { lock.unlock() }
        self.configuration = configuration

        if storage.count > configuration.capacity {
            storage.removeFirst(storage.count - configuration.capacity)
        }
    }

    func record(_ event: LTLogEvent) {
        lock.lock()
        defer { lock.unlock() }

        guard configuration.shouldRecord(level: event.level) else {
            return
        }

        storage.append(LTBreadcrumb(event: event))

        if storage.count > configuration.capacity {
            storage.removeFirst(storage.count - configuration.capacity)
        }
    }

    func removeAll() {
        lock.lock()
        defer { lock.unlock() }
        storage.removeAll()
    }
}
