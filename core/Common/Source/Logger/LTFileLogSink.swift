//
//  LTFileLogSink.swift
//  LTCommon
//
//  Created by Renjun Li on 2026/4/30.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

public enum LTFileLogBufferOverflowStrategy: String, Sendable, Equatable {
    case dropOldest
    case dropNewest
}

public struct LTFileLogConfiguration: Sendable, Equatable {
    public let directoryURL: URL
    public let filePrefix: String
    public let maximumFileSize: Int
    public let maximumFileCount: Int
    public let minimumLevel: LTLogLevel
    public let includeNonExportableEvents: Bool
    public let flushInterval: TimeInterval
    public let flushEventCount: Int
    public let flushByteCount: Int
    public let maximumBufferedEventCount: Int
    public let maximumBufferedBytes: Int
    public let overflowStrategy: LTFileLogBufferOverflowStrategy

    public init(
        directoryURL: URL = LTFileLogConfiguration.defaultDirectoryURL(),
        filePrefix: String = "lt-log",
        maximumFileSize: Int = 1024 * 1024,
        maximumFileCount: Int = 5,
        minimumLevel: LTLogLevel = .notice,
        includeNonExportableEvents: Bool = false,
        flushInterval: TimeInterval = 5,
        flushEventCount: Int = 20,
        flushByteCount: Int = 64 * 1024,
        maximumBufferedEventCount: Int = 500,
        maximumBufferedBytes: Int = 512 * 1024,
        overflowStrategy: LTFileLogBufferOverflowStrategy = .dropOldest
    ) {
        self.directoryURL = directoryURL
        self.filePrefix = filePrefix
        self.maximumFileSize = max(1024, maximumFileSize)
        self.maximumFileCount = max(1, maximumFileCount)
        self.minimumLevel = minimumLevel
        self.includeNonExportableEvents = includeNonExportableEvents
        self.flushInterval = max(0, flushInterval)
        self.flushEventCount = max(1, flushEventCount)
        self.flushByteCount = max(1024, flushByteCount)
        self.maximumBufferedEventCount = max(1, maximumBufferedEventCount)
        self.maximumBufferedBytes = max(self.flushByteCount, maximumBufferedBytes)
        self.overflowStrategy = overflowStrategy
    }

    public static func defaultDirectoryURL() -> URL {
        let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        return (cachesURL ?? FileManager.default.temporaryDirectory)
            .appendingPathComponent("LTLogs", isDirectory: true)
    }
}

public final class LTFileLogSink: LTLogSink, @unchecked Sendable {
    public let configuration: LTFileLogConfiguration

    private static let queueSpecificKey = DispatchSpecificKey<Void>()

    private let queue = DispatchQueue(label: "com.littlethings.ltlog.file-sink")
    private let encoder: JSONEncoder
    private let newlineData = Data("\n".utf8)

    private var currentFileURL: URL
    private var currentFileSize = 0
    private var currentFileHandle: FileHandle?
    private var buffer: [Data] = []
    private var bufferedBytes = 0
    private var flushTimer: DispatchSourceTimer?
#if canImport(UIKit)
    private var lifecycleObservers: [NSObjectProtocol] = []
#endif

    public init(configuration: LTFileLogConfiguration = .init()) {
        self.configuration = configuration
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
        self.currentFileURL = Self.makeLogFileURL(
            directoryURL: configuration.directoryURL,
            filePrefix: configuration.filePrefix
        )
        queue.setSpecific(key: Self.queueSpecificKey, value: ())
        queue.sync {
            try? FileManager.default.createDirectory(
                at: configuration.directoryURL,
                withIntermediateDirectories: true
            )
            purgeOldFiles()
        }
        startFlushTimer()
        registerLifecycleFlush()
    }

    deinit {
        flushTimer?.cancel()
#if canImport(UIKit)
        lifecycleObservers.forEach(NotificationCenter.default.removeObserver)
#endif
        syncOnQueue {
            flushOnQueue(synchronize: true)
            closeCurrentFileHandle()
        }
    }

    public func log(_ event: LTLogEvent) {
        guard event.level >= configuration.minimumLevel,
              configuration.includeNonExportableEvents || event.message != nil
        else {
            return
        }

        queue.async { [self] in
            enqueue(event)
        }
    }

    public func flush() {
        queue.async { [weak self] in
            self?.flushOnQueue()
        }
    }

    public func flushAndWait() {
        syncOnQueue {
            flushOnQueue(synchronize: true)
        }
    }

    public func logFileURLs() -> [URL] {
        syncOnQueue {
            flushOnQueue(synchronize: true)
            return logFiles()
        }
    }

    public func exportFeedbackLogs(
        breadcrumbs: [LTBreadcrumb] = []
    ) throws -> URL {
        try LTLogFeedbackExporter.export(fileLogSinks: [self], breadcrumbs: breadcrumbs)
    }

    private func startFlushTimer() {
        guard configuration.flushInterval > 0 else {
            return
        }

        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(
            deadline: .now() + configuration.flushInterval,
            repeating: configuration.flushInterval
        )
        timer.setEventHandler { [weak self] in
            self?.flushOnQueue()
        }
        timer.resume()
        flushTimer = timer
    }

    private func registerLifecycleFlush() {
#if canImport(UIKit)
        let notificationCenter = NotificationCenter.default
        lifecycleObservers = [
            notificationCenter.addObserver(
                forName: UIApplication.didEnterBackgroundNotification,
                object: nil,
                queue: nil
            ) { [weak self] _ in
                self?.flushAndWait()
            },
            notificationCenter.addObserver(
                forName: UIApplication.willTerminateNotification,
                object: nil,
                queue: nil
            ) { [weak self] _ in
                self?.flushAndWait()
            }
        ]
#endif
    }

    private func enqueue(_ event: LTLogEvent) {
        do {
            let data = try encoder.encode(event)
            var record = Data()
            record.reserveCapacity(data.count + newlineData.count)
            record.append(data)
            record.append(newlineData)

            if record.count >= configuration.maximumBufferedBytes {
                flushOnQueue()
                try write(record)
                return
            }

            buffer.append(record)
            bufferedBytes += record.count
            enforceBufferLimits()

            if shouldFlush {
                flushOnQueue()
            }
        } catch {
            // Logging sinks must never crash their host app.
        }
    }

    private var shouldFlush: Bool {
        buffer.count >= configuration.flushEventCount ||
        bufferedBytes >= configuration.flushByteCount
    }

    private func enforceBufferLimits() {
        guard buffer.count > configuration.maximumBufferedEventCount ||
              bufferedBytes > configuration.maximumBufferedBytes
        else {
            return
        }

        switch configuration.overflowStrategy {
        case .dropNewest:
            guard let dropped = buffer.popLast() else {
                return
            }
            bufferedBytes -= dropped.count
        case .dropOldest:
            while buffer.count > configuration.maximumBufferedEventCount ||
                    bufferedBytes > configuration.maximumBufferedBytes {
                guard buffer.isEmpty == false else {
                    bufferedBytes = 0
                    return
                }

                let dropped = buffer.removeFirst()
                bufferedBytes -= dropped.count
            }
        }
    }

    private func flushOnQueue(synchronize: Bool = false) {
        guard buffer.isEmpty == false else {
            if synchronize {
                currentFileHandle?.synchronizeFile()
            }
            return
        }

        var data = Data()
        data.reserveCapacity(bufferedBytes)
        buffer.forEach { data.append($0) }
        buffer.removeAll(keepingCapacity: true)
        bufferedBytes = 0

        do {
            try write(data)

            if synchronize {
                currentFileHandle?.synchronizeFile()
            }
        } catch {
            // Logging sinks must never crash their host app.
        }
    }

    private func write(_ data: Data) throws {
        let didRotate = try rotateIfNeeded(additionalBytes: data.count)
        let handle = try openCurrentFileHandle()
        try handle.write(contentsOf: data)
        currentFileSize += data.count

        if didRotate || currentFileSize >= configuration.maximumFileSize {
            purgeOldFiles()
        }
    }

    private func openCurrentFileHandle() throws -> FileHandle {
        if let currentFileHandle {
            return currentFileHandle
        }

        try FileManager.default.createDirectory(
            at: configuration.directoryURL,
            withIntermediateDirectories: true
        )

        if FileManager.default.fileExists(atPath: currentFileURL.path) == false {
            FileManager.default.createFile(atPath: currentFileURL.path, contents: nil)
        }

        let handle = try FileHandle(forWritingTo: currentFileURL)
        try handle.seekToEnd()
        currentFileSize = fileSize(at: currentFileURL)
        currentFileHandle = handle
        return handle
    }

    @discardableResult
    private func rotateIfNeeded(additionalBytes: Int) throws -> Bool {
        guard currentFileSize > 0,
              currentFileSize + additionalBytes > configuration.maximumFileSize
        else {
            return false
        }

        closeCurrentFileHandle()
        currentFileURL = Self.makeLogFileURL(
            directoryURL: configuration.directoryURL,
            filePrefix: configuration.filePrefix
        )
        currentFileSize = 0
        return true
    }

    private func closeCurrentFileHandle() {
        currentFileHandle?.closeFile()
        currentFileHandle = nil
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

    private func syncOnQueue<T>(_ work: () -> T) -> T {
        if DispatchQueue.getSpecific(key: Self.queueSpecificKey) != nil {
            return work()
        } else {
            return queue.sync(execute: work)
        }
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
