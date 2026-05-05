//
//  LTBCrashContextStore.swift
//  LTCommon
//
//  Created by Codex on 2026/5/5.
//

import Foundation

public struct LTBCrashContextConfiguration: Sendable, Equatable {
    public let breadcrumbCapacity: Int

    public init(breadcrumbCapacity: Int = 50) {
        self.breadcrumbCapacity = max(0, breadcrumbCapacity)
    }
}

final class LTBCrashContextStore: @unchecked Sendable {
    static let shared = LTBCrashContextStore()

    private let lock = NSRecursiveLock()
    private var configuration = LTBCrashContextConfiguration()
    private var userID: String?
    private var sessionID: String?
    private var deviceID: String?
    private var custom: [String: String] = [:]
    private var breadcrumbs: [LTBCrashReport.Breadcrumb] = []

    private init() { }

    func configure(_ configuration: LTBCrashContextConfiguration) {
        lock.lock()
        defer { lock.unlock() }
        self.configuration = configuration
        trimBreadcrumbsIfNeeded()
    }

    func setUserID(_ value: String?) {
        lock.lock()
        defer { lock.unlock() }
        userID = value
    }

    func setSessionID(_ value: String?) {
        lock.lock()
        defer { lock.unlock() }
        sessionID = value
    }

    func setDeviceID(_ value: String?) {
        lock.lock()
        defer { lock.unlock() }
        deviceID = value
    }

    func setCustomValue(_ value: String?, forKey key: String) {
        lock.lock()
        defer { lock.unlock() }

        if let value {
            custom[key] = value
        } else {
            custom.removeValue(forKey: key)
        }
    }

    func replaceCustomValues(_ values: [String: String]) {
        lock.lock()
        defer { lock.unlock() }
        custom = values
    }

    func addBreadcrumb(
        category: String,
        message: String?,
        level: String,
        metadata: [String: String],
        timestamp: TimeInterval = Date().timeIntervalSince1970
    ) {
        lock.lock()
        defer { lock.unlock() }

        breadcrumbs.append(
            .init(
                category: category,
                message: message,
                level: level,
                timestamp: timestamp,
                metadata: metadata
            )
        )
        trimBreadcrumbsIfNeeded()
    }

    func replaceBreadcrumbs(_ values: [LTBCrashReport.Breadcrumb]) {
        lock.lock()
        defer { lock.unlock() }
        breadcrumbs = values
        trimBreadcrumbsIfNeeded()
    }

    func snapshot() -> LTBCrashReport.Context {
        lock.lock()
        defer { lock.unlock() }
        return .init(
            userID: userID,
            sessionID: sessionID,
            deviceID: deviceID,
            custom: custom,
            breadcrumbs: breadcrumbs
        )
    }

    private func trimBreadcrumbsIfNeeded() {
        guard breadcrumbs.count > configuration.breadcrumbCapacity else { return }
        breadcrumbs.removeFirst(breadcrumbs.count - configuration.breadcrumbCapacity)
    }
}

