//
//  LTLog.swift
//  LTCommon
//
//  Created by Renjun Li on 2026/4/29.
//

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
}
