//
//  NetworkMonitorConfiguration.swift
//  Common
//
//  Created by LittleThings AI on 2026/05/17.
//

import Foundation

public struct NetworkMonitorConfiguration: Sendable {
    public let maxEntries: Int
    public let maxBodySize: Int

    public init(
        maxEntries: Int = 100,
        maxBodySize: Int = 1024 * 1024  // 1MB
    ) {
        self.maxEntries = maxEntries
        self.maxBodySize = maxBodySize
    }
}
