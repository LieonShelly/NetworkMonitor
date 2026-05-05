//
//  CrashReporter.swift
//  LTCommon
//
//  Created by Codex on 2026/5/5.
//

import Foundation

public enum CrashReporter {
    private static let queue = DispatchQueue(label: "com.littlethings.ltbugly.crash-reporter")
    nonisolated(unsafe)
    private static var uploader: LTBCrashUploading?
    nonisolated(unsafe)
    private static var store: LTBCrashReportStore?
    nonisolated(unsafe)
    private static var isStarted = false
    nonisolated(unsafe)
    private static var reportDirectoryURL: URL?

    public static func start(
        configuration: LTBCrashReporterConfiguration = .init(),
        uploader: LTBCrashUploading? = nil
    ) {
        queue.sync {
            guard isStarted == false else { return }

            let reportStore = LTBCrashReportStore(
                directoryURL: configuration.reportDirectoryURL,
                maximumReportCount: configuration.maximumReportCount
            )
            store = reportStore
            reportDirectoryURL = configuration.reportDirectoryURL
            LTBCrashContextStore.shared.configure(configuration.contextConfiguration)
            self.uploader = uploader ?? configuration.endpointURL.map {
                LTURLSessionCrashUploader(
                    endpointURL: $0,
                    headers: configuration.headers,
                    configuration: configuration.uploadConfiguration
                )
            }

            try? reportStore.prepareDirectory()
            reportStore.trimReportsIfNeeded()
            syncBreadcrumbsFromLogger()
            syncSignalContextTemplate()
            LTBCrashCapture.install(store: reportStore)
            isStarted = true
        }

        uploadPendingReports()
    }

    public static func uploadPendingReports() {
        queue.async {
            guard let store, let uploader else { return }

            let reports = store.pendingReports()
            guard reports.isEmpty == false else { return }

            for fileURL in reports {
                guard let data = try? Data(contentsOf: fileURL) else {
                    store.removeReport(at: fileURL)
                    continue
                }

                uploader.uploadCrashReport(data) { success in
                    guard success else { return }
                    store.removeReport(at: fileURL)
                }
            }
        }
    }

    public static func setUserID(_ value: String?) {
        LTBCrashContextStore.shared.setUserID(value)
        syncSignalContextTemplate()
    }

    public static func setSessionID(_ value: String?) {
        LTBCrashContextStore.shared.setSessionID(value)
        syncSignalContextTemplate()
    }

    public static func setDeviceID(_ value: String?) {
        LTBCrashContextStore.shared.setDeviceID(value)
        syncSignalContextTemplate()
    }

    public static func setCustomValue(_ value: String?, forKey key: String) {
        LTBCrashContextStore.shared.setCustomValue(value, forKey: key)
        syncSignalContextTemplate()
    }

    public static func setCustomValues(_ values: [String: String]) {
        LTBCrashContextStore.shared.replaceCustomValues(values)
        syncSignalContextTemplate()
    }

    public static func addBreadcrumb(
        _ message: String,
        category: String = "manual",
        level: String = "info",
        metadata: [String: String] = [:]
    ) {
        LTBCrashContextStore.shared.addBreadcrumb(
            category: category,
            message: message,
            level: level,
            metadata: metadata
        )
        syncSignalContextTemplate()
    }

    public static func syncBreadcrumbsFromLogger() {
        let breadcrumbs = LTLog.breadcrumbs.map {
            LTBCrashReport.Breadcrumb(
                category: $0.category,
                message: $0.message,
                level: String(describing: $0.level),
                timestamp: $0.timestamp.timeIntervalSince1970,
                metadata: $0.metadata
            )
        }
        LTBCrashContextStore.shared.replaceBreadcrumbs(breadcrumbs)
        syncSignalContextTemplate()
    }

    private static func syncSignalContextTemplate() {
        guard let directoryURL = reportDirectoryURL else { return }
        let payload = LTBCrashReportBuilder.makeSignalContextPayload()
        let fileURL = directoryURL.appendingPathComponent("signal-context.json")
        if let data = try? JSONEncoder().encode(payload) {
            try? data.write(to: fileURL, options: .atomic)
        }
        LTBCrashSignalBridge.updateContext(payload)
    }
}
