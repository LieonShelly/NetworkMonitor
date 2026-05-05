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
            self.uploader = uploader ?? configuration.endpointURL.map {
                LTURLSessionCrashUploader(endpointURL: $0, headers: configuration.headers)
            }

            try? reportStore.prepareDirectory()
            reportStore.trimReportsIfNeeded()
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
}
