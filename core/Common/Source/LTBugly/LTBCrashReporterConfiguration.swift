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
    public let redactionPolicy: LTBCrashRedactionPolicy

    public init(
        endpointURL: URL? = nil,
        headers: [String: String] = [:],
        maximumReportCount: Int = 10,
        reportDirectoryURL: URL = LTBCrashReporterConfiguration.defaultReportDirectoryURL(),
        contextConfiguration: LTBCrashContextConfiguration = .init(),
        uploadConfiguration: LTBCrashUploadConfiguration = .init(),
        redactionPolicy: LTBCrashRedactionPolicy = .default
    ) {
        self.endpointURL = endpointURL
        self.headers = headers
        self.maximumReportCount = max(1, maximumReportCount)
        self.reportDirectoryURL = reportDirectoryURL
        self.contextConfiguration = contextConfiguration
        self.uploadConfiguration = uploadConfiguration
        self.redactionPolicy = redactionPolicy
    }

    public static func defaultReportDirectoryURL() -> URL {
        let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        return (cachesURL ?? URL(fileURLWithPath: NSTemporaryDirectory()))
            .appendingPathComponent("LTBugly", isDirectory: true)
            .appendingPathComponent("CrashReports", isDirectory: true)
    }

    public static func defaultContextDirectoryURL() -> URL {
        let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        return (cachesURL ?? URL(fileURLWithPath: NSTemporaryDirectory()))
            .appendingPathComponent("LTBugly", isDirectory: true)
            .appendingPathComponent("Context", isDirectory: true)
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

public struct LTBCrashRedactionPolicy: Sendable, Equatable {
    public enum KeyMode: Sendable, Equatable {
        case blacklist
        case whitelist
    }

    public let keyMode: KeyMode
    public let sensitiveKeys: Set<String>
    public let allowedKeys: Set<String>
    public let replacement: String
    public let redactEmails: Bool
    public let redactPhoneNumbers: Bool

    public init(
        keyMode: KeyMode = .blacklist,
        sensitiveKeys: Set<String>,
        allowedKeys: Set<String> = [],
        replacement: String = "[REDACTED]",
        redactEmails: Bool = true,
        redactPhoneNumbers: Bool = true
    ) {
        self.keyMode = keyMode
        self.sensitiveKeys = Set(sensitiveKeys.map { $0.lowercased() })
        self.allowedKeys = Set(allowedKeys.map { $0.lowercased() })
        self.replacement = replacement
        self.redactEmails = redactEmails
        self.redactPhoneNumbers = redactPhoneNumbers
    }

    public static let `default` = LTBCrashRedactionPolicy(
        sensitiveKeys: [
            "token", "access_token", "refresh_token", "authorization",
            "cookie", "set-cookie", "password", "passwd", "secret",
            "phone", "mobile", "email", "id_card"
        ]
    )
}

public struct LTBCrashPersistenceConfiguration: Sendable, Equatable {
    public let debounceInterval: TimeInterval
    public let breadcrumbFileCount: Int
    public let maximumBreadcrumbsPerFile: Int

    public init(
        debounceInterval: TimeInterval = 1,
        breadcrumbFileCount: Int = 3,
        maximumBreadcrumbsPerFile: Int = 50
    ) {
        self.debounceInterval = max(0, debounceInterval)
        self.breadcrumbFileCount = max(1, breadcrumbFileCount)
        self.maximumBreadcrumbsPerFile = max(1, maximumBreadcrumbsPerFile)
    }
}
