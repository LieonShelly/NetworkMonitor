//
//  LTBCrashEvent.swift
//  LTCommon
//
//  Created by Codex on 2026/5/6.
//

import Foundation

public struct LTBCrashEvent: Codable, Sendable, Equatable {
    public let id: String
    public let timestamp: TimeInterval
    public let kind: Kind
    public let app: LTBCrashReport.App
    public let device: LTBCrashReport.Device
    public let context: LTBCrashReport.Context
    public let details: [String: String]

    public enum Kind: String, Codable, Sendable, Equatable {
        case appHangRisk = "app_hang_risk"
        case watchdogRisk = "watchdog_risk"
        case memoryPressure = "memory_pressure"
        case abnormalTermination = "abnormal_termination"
    }
}

