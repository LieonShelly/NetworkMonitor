//
//  LTBCrashReportStore.swift
//  LTCommon
//
//  Created by Codex on 2026/5/5.
//

import Foundation

final class LTBCrashReportStore: @unchecked Sendable {
    private let directoryURL: URL
    private let maximumReportCount: Int
    private let fileManager: FileManager
    private let encoder: JSONEncoder

    init(
        directoryURL: URL,
        maximumReportCount: Int,
        fileManager: FileManager = .default
    ) {
        self.directoryURL = directoryURL
        self.maximumReportCount = max(1, maximumReportCount)
        self.fileManager = fileManager
        self.encoder = JSONEncoder()
        self.encoder.outputFormatting = [.sortedKeys]
    }

    var directoryPath: String {
        directoryURL.path
    }

    func prepareDirectory() throws {
        try fileManager.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )
    }

    func save(_ report: LTBCrashReport) {
        do {
            try prepareDirectory()
            let fileURL = directoryURL.appendingPathComponent("\(report.crashID).json")
            let data = try encoder.encode(report)
            try data.write(to: fileURL, options: .atomic)
            trimReportsIfNeeded()
        } catch {
            assertionFailure("Failed to persist crash report: \(error)")
        }
    }

    func save(_ event: LTBCrashEvent) {
        do {
            try prepareDirectory()
            let fileURL = directoryURL.appendingPathComponent("event-\(event.id).json")
            let data = try encoder.encode(event)
            try data.write(to: fileURL, options: .atomic)
            trimReportsIfNeeded()
        } catch {
            assertionFailure("Failed to persist crash event: \(error)")
        }
    }

    func pendingReports() -> [URL] {
        guard let files = try? fileManager.contentsOfDirectory(
            at: directoryURL,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        return files
            .filter { $0.pathExtension == "json" && $0.lastPathComponent != "signal-context.json" }
            .sortedByModificationDate()
    }

    func removeReport(at fileURL: URL) {
        try? fileManager.removeItem(at: fileURL)
    }

    func trimReportsIfNeeded() {
        let reports = pendingReports()
        guard reports.count > maximumReportCount else { return }

        reports.prefix(reports.count - maximumReportCount).forEach {
            removeReport(at: $0)
        }
    }
}

private extension Array where Element == URL {
    func sortedByModificationDate() -> [URL] {
        sorted { lhs, rhs in
            lhs.modificationDate < rhs.modificationDate
        }
    }
}

private extension URL {
    var modificationDate: Date {
        ((try? resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate) ?? .distantPast
    }
}
