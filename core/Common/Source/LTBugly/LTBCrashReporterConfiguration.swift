//
//  LTBCrashReporterConfiguration.swift
//  LTCommon
//
//  Created by Codex on 2026/5/5.
//

import Foundation

public struct LTBCrashReporterConfiguration: Sendable, Equatable {
    public let endpointURL: URL?
    public let headers: [String: String]
    public let maximumReportCount: Int
    public let reportDirectoryURL: URL
    public let contextConfiguration: LTBCrashContextConfiguration
    public let uploadConfiguration: LTBCrashUploadConfiguration

    public init(
        endpointURL: URL? = nil,
        headers: [String: String] = [:],
        maximumReportCount: Int = 10,
        reportDirectoryURL: URL = LTBCrashReporterConfiguration.defaultReportDirectoryURL(),
        contextConfiguration: LTBCrashContextConfiguration = .init(),
        uploadConfiguration: LTBCrashUploadConfiguration = .init()
    ) {
        self.endpointURL = endpointURL
        self.headers = headers
        self.maximumReportCount = max(1, maximumReportCount)
        self.reportDirectoryURL = reportDirectoryURL
        self.contextConfiguration = contextConfiguration
        self.uploadConfiguration = uploadConfiguration
    }

    public static func defaultReportDirectoryURL() -> URL {
        let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        return (cachesURL ?? URL(fileURLWithPath: NSTemporaryDirectory()))
            .appendingPathComponent("LTBugly", isDirectory: true)
            .appendingPathComponent("CrashReports", isDirectory: true)
    }
}

public struct LTBCrashUploadConfiguration: Sendable, Equatable {
    public let maximumRetryCount: Int
    public let retryBaseDelay: TimeInterval
    public let enablesCompression: Bool
    public let allowsCellularAccess: Bool
    public let allowsExpensiveNetworkAccess: Bool
    public let allowsConstrainedNetworkAccess: Bool
    public let waitsForConnectivity: Bool
    public let rateLimitPolicy: LTLogRateLimitPolicy

    public init(
        maximumRetryCount: Int = 2,
        retryBaseDelay: TimeInterval = 2,
        enablesCompression: Bool = true,
        allowsCellularAccess: Bool = true,
        allowsExpensiveNetworkAccess: Bool = true,
        allowsConstrainedNetworkAccess: Bool = true,
        waitsForConnectivity: Bool = false,
        rateLimitPolicy: LTLogRateLimitPolicy = .init(maxEvents: 10, interval: 60)
    ) {
        self.maximumRetryCount = max(0, maximumRetryCount)
        self.retryBaseDelay = max(0, retryBaseDelay)
        self.enablesCompression = enablesCompression
        self.allowsCellularAccess = allowsCellularAccess
        self.allowsExpensiveNetworkAccess = allowsExpensiveNetworkAccess
        self.allowsConstrainedNetworkAccess = allowsConstrainedNetworkAccess
        self.waitsForConnectivity = waitsForConnectivity
        self.rateLimitPolicy = rateLimitPolicy
    }
}
