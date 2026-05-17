//
//  NetworkMonitorStore.swift
//  Common
//
//  Created by LittleThings AI on 2026/05/17.
//

import Foundation
import SwiftUI

@Observable
@MainActor
public final class NetworkMonitorStore {
    public static let shared = NetworkMonitorStore()

    public private(set) var entries: [NetworkMonitorEntry] = []
    public var isExpanded: Bool = false
    public var isEnabled: Bool = false

    public var configuration: NetworkMonitorConfiguration

    private init(configuration: NetworkMonitorConfiguration = NetworkMonitorConfiguration()) {
        self.configuration = configuration
    }

    public func start() {
        guard !isEnabled else { return }
        NetworkMonitorCore.shared.register()
        
        isEnabled = true
    }
    
    public func registeredConfiguration() -> URLSessionConfiguration? {
        return NetworkMonitorCore.shared.registeredConfiguration
    }

    public func stop() {
        guard isEnabled else { return }
        NetworkMonitorCore.shared.unregister()
        isEnabled = false
    }

    public func clear() {
        entries.removeAll()
    }

    public func recordEntry(_ entry: NetworkMonitorEntry) {
        entries.insert(entry, at: 0)
        if entries.count > configuration.maxEntries {
            entries.removeLast()
        }
    }

    public func updateEntry(id: UUID, update: (inout NetworkMonitorEntry) -> Void) {
        guard let index = entries.firstIndex(where: { $0.id == id }) else { return }
        var updated = entries[index]
        update(&updated)
        entries[index] = updated
    }

    public func updateEntry(_ entry: NetworkMonitorEntry, update: (inout NetworkMonitorEntry) -> Void) {
        updateEntry(id: entry.id, update: update)
    }
}
