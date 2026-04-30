//
//  LTLogFeedbackExporter.swift
//  LTCommon
//
//  Created by Renjun Li on 2026/4/30.
//

import Foundation

public enum LTLogFeedbackExportError: Error, Sendable {
    case noFileLogSink
}

public enum LTLogFeedbackExporter {
    public static func export(
        fileLogSinks: [LTFileLogSink],
        breadcrumbs: [LTBreadcrumb] = [],
        outputDirectoryURL: URL = FileManager.default.temporaryDirectory
    ) throws -> URL {
        guard fileLogSinks.isEmpty == false else {
            throw LTLogFeedbackExportError.noFileLogSink
        }

        let exportURL = outputDirectoryURL.appendingPathComponent(exportFileName())
        FileManager.default.createFile(atPath: exportURL.path, contents: nil)
        let handle = try FileHandle(forWritingTo: exportURL)
        defer { handle.closeFile() }

        for sink in fileLogSinks {
            for fileURL in sink.logFileURLs() {
                guard let data = try? Data(contentsOf: fileURL), data.isEmpty == false else {
                    continue
                }
                try handle.write(contentsOf: data)
            }
        }

        if breadcrumbs.isEmpty == false {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            for breadcrumb in breadcrumbs {
                let record = LTFeedbackLogRecord(type: "breadcrumb", breadcrumb: breadcrumb)
                let data = try encoder.encode(record)
                try handle.write(contentsOf: data + Data("\n".utf8))
            }
        }

        return exportURL
    }

    private static func exportFileName() -> String {
        let timestamp = ISO8601DateFormatter()
            .string(from: Date())
            .replacingOccurrences(of: ":", with: "-")
        return "lt-feedback-logs-\(timestamp).jsonl"
    }
}

private struct LTFeedbackLogRecord: Codable {
    let type: String
    let breadcrumb: LTBreadcrumb
}
