//
//  LTFileLogSink.swift
//  LTCommon
//
//  Created by Renjun Li on 2026/4/30.
//

import Foundation

public struct LTFileLogConfiguration: Sendable, Equatable {
    public let directoryURL: URL
    public let filePrefix: String
    public let maximumFileSize: Int
    public let maximumFileCount: Int
    public let minimumLevel: LTLogLevel
    public let includeNonExportableEvents: Bool

    public init(
        directoryURL: URL = LTFileLogConfiguration.defaultDirectoryURL(),
        filePrefix: String = "lt-log",
        maximumFileSize: Int = 1024 * 1024,
        maximumFileCount: Int = 5,
        minimumLevel: LTLogLevel = .notice,
        includeNonExportableEvents: Bool = false
    ) {
        self.directoryURL = directoryURL
        self.filePrefix = filePrefix
        self.maximumFileSize = max(1024, maximumFileSize)
        self.maximumFileCount = max(1, maximumFileCount)
        self.minimumLevel = minimumLevel
        self.includeNonExportableEvents = includeNonExportableEvents
    }

    public static func defaultDirectoryURL() -> URL {
        let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        return (cachesURL ?? FileManager.default.temporaryDirectory)
            .appendingPathComponent("LTLogs", isDirectory: true)
    }
}

public final class LTFileLogSink: LTLogSink, @unchecked Sendable {
    public let configuration: LTFileLogConfiguration

    private let queue = DispatchQueue(label: "com.littlethings.ltlog.file-sink")
    private let encoder: JSONEncoder
    private var currentFileURL: URL

    public init(configuration: LTFileLogConfiguration = .init()) {
        self.configuration = configuration
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
        self.currentFileURL = Self.makeLogFileURL(
            directoryURL: configuration.directoryURL,
            filePrefix: configuration.filePrefix
        )
        queue.sync {
            try? FileManager.default.createDirectory(
                at: configuration.directoryURL,
                withIntermediateDirectories: true
            )
            purgeOldFiles()
        }
    }

    public func log(_ event: LTLogEvent) {
        guard event.level >= configuration.minimumLevel,
              configuration.includeNonExportableEvents || event.message != nil
        else {
            return
        }

        queue.async { [self] in
            write(event)
        }
    }

    public func logFileURLs() -> [URL] {
        queue.sync {
            logFiles()
        }
    }

    public func exportFeedbackLogs(
        breadcrumbs: [LTBreadcrumb] = []
    ) throws -> URL {
        try LTLogFeedbackExporter.export(fileLogSinks: [self], breadcrumbs: breadcrumbs)
    }

    private func write(_ event: LTLogEvent) {
        do {
            try rotateIfNeeded()
            let data = try encoder.encode(event)
            try append(data + Data("\n".utf8), to: currentFileURL)
        } catch {
            // Logging sinks must never crash their host app.
        }
    }

    private func append(_ data: Data, to fileURL: URL) throws {
        if FileManager.default.fileExists(atPath: fileURL.path) == false {
            try data.write(to: fileURL, options: .atomic)
            return
        }

        let handle = try FileHandle(forWritingTo: fileURL)
        defer { handle.closeFile() }
        try handle.seekToEnd()
        try handle.write(contentsOf: data)
    }

    private func rotateIfNeeded() throws {
        try FileManager.default.createDirectory(
            at: configuration.directoryURL,
            withIntermediateDirectories: true
        )

        let size = fileSize(at: currentFileURL)
        guard size >= configuration.maximumFileSize else {
            return
        }

        currentFileURL = Self.makeLogFileURL(
            directoryURL: configuration.directoryURL,
            filePrefix: configuration.filePrefix
        )
        purgeOldFiles()
    }

    private func purgeOldFiles() {
        let files = logFiles()
        guard files.count > configuration.maximumFileCount else {
            return
        }

        files
            .prefix(files.count - configuration.maximumFileCount)
            .forEach { try? FileManager.default.removeItem(at: $0) }
    }

    private func logFiles() -> [URL] {
        guard let urls = try? FileManager.default.contentsOfDirectory(
            at: configuration.directoryURL,
            includingPropertiesForKeys: [.creationDateKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        return urls
            .filter { $0.lastPathComponent.hasPrefix(configuration.filePrefix) }
            .sorted { lhs, rhs in
                creationDate(for: lhs) < creationDate(for: rhs)
            }
    }

    private func fileSize(at url: URL) -> Int {
        let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
        return attributes?[.size] as? Int ?? 0
    }

    private func creationDate(for url: URL) -> Date {
        let values = try? url.resourceValues(forKeys: [.creationDateKey])
        return values?.creationDate ?? .distantPast
    }

    private static func makeLogFileURL(directoryURL: URL, filePrefix: String) -> URL {
        let timestamp = ISO8601DateFormatter()
            .string(from: Date())
            .replacingOccurrences(of: ":", with: "-")
        return directoryURL.appendingPathComponent("\(filePrefix)-\(timestamp)-\(UUID().uuidString).jsonl")
    }
}
