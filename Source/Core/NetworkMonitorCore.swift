//
//  NetworkMonitorCore.swift
//  Common
//
//  Created by LittleThings AI on 2026/05/17.
//

import Foundation

/// Central manager for NetworkMonitor that handles URLProtocol registration.
/// Note: URLProtocol only captures requests made AFTER registration.
/// For best results, register as early as possible in app lifecycle.
public final class NetworkMonitorCore: @unchecked Sendable {
    public static let shared = NetworkMonitorCore()

    private let lock = NSLock()
    private var isRegistered = false

    /// The registered configuration that includes NetworkMonitorURLProtocol.
    /// Use this configuration when creating URLSessions to ensure monitoring works.
    public private(set) var registeredConfiguration: URLSessionConfiguration?

    private init() {}

    /// Registers the NetworkMonitorURLProtocol with the default URLSessionConfiguration.
    /// This enables capturing requests from all URLSessions created with the registered config
    /// that are created AFTER this method is called.
    public func register() {
        lock.lock()
        defer { lock.unlock() }

        guard !isRegistered else { return }

        let config = URLSessionConfiguration.default
        var protocols: [AnyClass] = config.protocolClasses ?? []
        
        protocols.removeAll { $0 == NetworkMonitorURLProtocol.self }
        protocols.insert(NetworkMonitorURLProtocol.self, at: 0)
        config.protocolClasses = protocols

        self.registeredConfiguration = config
        isRegistered = true
    }

    /// Unregisters the URLProtocol.
    public func unregister() {
        lock.lock()
        defer { lock.unlock() }

        isRegistered = false
        registeredConfiguration = nil
    }
}
