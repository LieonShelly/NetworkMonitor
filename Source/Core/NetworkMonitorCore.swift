//
//  NetworkMonitorCore.swift
//  Common
//
//  Created by LittleThings AI on 2026/05/17.
//

import Foundation

public final class NetworkMonitorCore: @unchecked Sendable {
    public static let shared = NetworkMonitorCore()

    private let lock = NSLock()
    private var isRegistered = false

    public private(set) var registeredConfiguration: URLSessionConfiguration?

    private init() {}

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

    public func unregister() {
        lock.lock()
        defer { lock.unlock() }

        isRegistered = false
        registeredConfiguration = nil
    }
}
