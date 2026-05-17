//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation

public enum LTLog {
    public static func configure(_ configuration: LTLogConfiguration) {
        LTLogStore.shared.configure(configuration)
    }

    public static var configuration: LTLogConfiguration {
        LTLogStore.shared.currentConfiguration()
    }

    public static func logger(category: String) -> LTLogger {
        LTLogger(
            subsystem: LTLogStore.shared.currentConfiguration().subsystem,
            category: category
        )
    }

    public static func setMinimumLevel(_ minimumLevel: LTLogLevel) {
        LTLogStore.shared.setMinimumLevel(minimumLevel)
    }

    public static func addSink(_ sink: any LTLogSink) {
        LTLogStore.shared.addSink(sink)
    }

    public static func removeAllSinks() {
        LTLogStore.shared.removeAllSinks()
    }

    public static var breadcrumbs: [LTBreadcrumb] {
        LTBreadcrumbStore.shared.breadcrumbs
    }

    public static func addBreadcrumb(
        _ message: String,
        category: String = "manual",
        metadata: LTLogMetadata = [:],
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        let configuration = LTLogStore.shared.currentConfiguration()
        let event = LTLogEvent(
            level: .info,
            subsystem: configuration.subsystem,
            category: category,
            environment: configuration.environment,
            message: message,
            metadata: metadata,
            file: file.description,
            function: function.description,
            line: line
        )
        LTBreadcrumbStore.shared.record(event)
    }

    public static func removeAllBreadcrumbs() {
        LTBreadcrumbStore.shared.removeAll()
    }

    public static func exportFeedbackLogs(
        includeBreadcrumbs: Bool = true
    ) throws -> URL {
        try LTLogFeedbackExporter.export(
            fileLogSinks: LTLogStore.shared.fileLogSinks(),
            breadcrumbs: includeBreadcrumbs ? LTBreadcrumbStore.shared.breadcrumbs : []
        )
    }
}
