//
//  LTBCrashContextStore.swift
//  LTCommon
//
//  Created by Codex on 2026/5/5.
//

import Foundation

public struct LTBCrashContextConfiguration: Sendable, Equatable {
    public let breadcrumbCapacity: Int
    public let persistenceDirectoryURL: URL?
    public let persistenceConfiguration: LTBCrashPersistenceConfiguration

    public init(
        breadcrumbCapacity: Int = 50,
        persistenceDirectoryURL: URL? = LTBCrashReporterConfiguration.defaultContextDirectoryURL(),
        persistenceConfiguration: LTBCrashPersistenceConfiguration = .init()
    ) {
        self.breadcrumbCapacity = max(0, breadcrumbCapacity)
        self.persistenceDirectoryURL = persistenceDirectoryURL
        self.persistenceConfiguration = persistenceConfiguration
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
    private var persistenceDirectoryURL: URL?
    private var redactionPolicy: LTBCrashRedactionPolicy = .default
    private var pendingPersistWorkItem: DispatchWorkItem?
    private let persistenceQueue = DispatchQueue(label: "com.littlethings.ltbugly.context.persistence")

    private init() { }

    func configure(
        _ configuration: LTBCrashContextConfiguration,
        redactionPolicy: LTBCrashRedactionPolicy
    ) {
        lock.lock()
        defer { lock.unlock() }
        self.configuration = configuration
        self.persistenceDirectoryURL = configuration.persistenceDirectoryURL
        self.redactionPolicy = redactionPolicy
        restorePersistedStateIfNeeded()
        trimBreadcrumbsIfNeeded()
        schedulePersistState(immediately: true)
    }

    func setUserID(_ value: String?) {
        lock.lock()
        defer { lock.unlock() }
        userID = value.map { LTBCrashRedactor.redact($0, key: "user_id", policy: redactionPolicy) }
        schedulePersistState()
    }

    func setSessionID(_ value: String?) {
        lock.lock()
        defer { lock.unlock() }
        sessionID = value.map { LTBCrashRedactor.redact($0, key: "session_id", policy: redactionPolicy) }
        schedulePersistState()
    }

    func setDeviceID(_ value: String?) {
        lock.lock()
        defer { lock.unlock() }
        deviceID = value.map { LTBCrashRedactor.redact($0, key: "device_id", policy: redactionPolicy) }
        schedulePersistState()
    }

    func setCustomValue(_ value: String?, forKey key: String) {
        lock.lock()
        defer { lock.unlock() }

        if let value {
            custom[key] = LTBCrashRedactor.redact(value, key: key, policy: redactionPolicy)
        } else {
            custom.removeValue(forKey: key)
        }
        schedulePersistState()
    }

    func replaceCustomValues(_ values: [String: String]) {
        lock.lock()
        defer { lock.unlock() }
        custom = values.reduce(into: [:]) { partialResult, pair in
            partialResult[pair.key] = LTBCrashRedactor.redact(pair.value, key: pair.key, policy: redactionPolicy)
        }
        schedulePersistState()
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
                message: message.map { LTBCrashRedactor.redact($0, policy: redactionPolicy) },
                level: level,
                timestamp: timestamp,
                metadata: LTBCrashRedactor.redact(metadata: metadata, policy: redactionPolicy)
            )
        )
        trimBreadcrumbsIfNeeded()
        schedulePersistState()
    }

    func replaceBreadcrumbs(_ values: [LTBCrashReport.Breadcrumb]) {
        lock.lock()
        defer { lock.unlock() }
        breadcrumbs = values.map {
            .init(
                category: $0.category,
                message: $0.message.map { LTBCrashRedactor.redact($0, policy: redactionPolicy) },
                level: $0.level,
                timestamp: $0.timestamp,
                metadata: LTBCrashRedactor.redact(metadata: $0.metadata, policy: redactionPolicy)
            )
        }
        trimBreadcrumbsIfNeeded()
        schedulePersistState()
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

    private func schedulePersistState(immediately: Bool = false) {
        let snapshot = persistedStateSnapshot()
        let persistenceDirectoryURL = self.persistenceDirectoryURL
        let persistenceConfiguration = configuration.persistenceConfiguration

        pendingPersistWorkItem?.cancel()
        let workItem = DispatchWorkItem { [self] in
            guard let persistenceDirectoryURL else { return }
            self.persistSnapshot(
                snapshot,
                to: persistenceDirectoryURL,
                configuration: persistenceConfiguration
            )
        }
        pendingPersistWorkItem = workItem

        if immediately {
            persistenceQueue.async(execute: workItem)
        } else {
            persistenceQueue.asyncAfter(deadline: .now() + persistenceConfiguration.debounceInterval, execute: workItem)
        }
    }

    private func persistedStateSnapshot() -> PersistedState {
        PersistedState(
            userID: userID,
            sessionID: sessionID,
            deviceID: deviceID,
            custom: custom,
            breadcrumbs: breadcrumbs
        )
    }

    private func persistSnapshot(
        _ state: PersistedState,
        to persistenceDirectoryURL: URL,
        configuration: LTBCrashPersistenceConfiguration
    ) {
        do {
            try FileManager.default.createDirectory(at: persistenceDirectoryURL, withIntermediateDirectories: true)
            let data = try JSONEncoder().encode(state)
            try data.write(to: persistenceDirectoryURL.appendingPathComponent("context.json"), options: .atomic)

            let breadcrumbs = state.breadcrumbs
            let chunkSize = configuration.maximumBreadcrumbsPerFile
            let chunks = stride(from: 0, to: breadcrumbs.count, by: chunkSize).map {
                Array(breadcrumbs[$0 ..< min($0 + chunkSize, breadcrumbs.count)])
            }
            let recentChunks = Array(chunks.suffix(configuration.breadcrumbFileCount))

            for index in 0 ..< configuration.breadcrumbFileCount {
                let fileURL = persistenceDirectoryURL.appendingPathComponent("breadcrumbs-\(index).json")
                if index < recentChunks.count {
                    let chunkData = try JSONEncoder().encode(recentChunks[index])
                    try chunkData.write(to: fileURL, options: .atomic)
                } else {
                    try? FileManager.default.removeItem(at: fileURL)
                }
            }
        } catch {
            assertionFailure("Failed to persist crash context: \(error)")
        }
    }

    private func restorePersistedStateIfNeeded() {
        guard let persistenceDirectoryURL else { return }
        let fileURL = persistenceDirectoryURL.appendingPathComponent("context.json")
        guard let data = try? Data(contentsOf: fileURL),
              let state = try? JSONDecoder().decode(PersistedState.self, from: data)
        else {
            return
        }

        userID = state.userID
        sessionID = state.sessionID
        deviceID = state.deviceID
        custom = state.custom
        breadcrumbs = state.breadcrumbs
    }
}

private struct PersistedState: Codable {
    let userID: String?
    let sessionID: String?
    let deviceID: String?
    let custom: [String: String]
    let breadcrumbs: [LTBCrashReport.Breadcrumb]

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case sessionID = "session_id"
        case deviceID = "device_id"
        case custom
        case breadcrumbs
    }
}
