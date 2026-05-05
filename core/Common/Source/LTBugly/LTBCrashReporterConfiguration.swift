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

    public init(
        endpointURL: URL? = nil,
        headers: [String: String] = [:],
        maximumReportCount: Int = 10,
        reportDirectoryURL: URL = LTBCrashReporterConfiguration.defaultReportDirectoryURL()
    ) {
        self.endpointURL = endpointURL
        self.headers = headers
        self.maximumReportCount = max(1, maximumReportCount)
        self.reportDirectoryURL = reportDirectoryURL
    }

    public static func defaultReportDirectoryURL() -> URL {
        let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        return (cachesURL ?? URL(fileURLWithPath: NSTemporaryDirectory()))
            .appendingPathComponent("LTBugly", isDirectory: true)
            .appendingPathComponent("CrashReports", isDirectory: true)
    }
}

