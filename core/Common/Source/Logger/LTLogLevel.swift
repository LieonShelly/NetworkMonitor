//
//  LTLogLevel.swift
//  LTCommon
//
//  Created by Renjun Li on 2026/4/29.
//

import OSLog

public enum LTLogLevel: Int, CaseIterable, Comparable, Sendable {
    case trace = 0
    case debug
    case info
    case notice
    case warning
    case error
    case fault

    public static func < (lhs: LTLogLevel, rhs: LTLogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension LTLogLevel {
    var osLogType: OSLogType {
        switch self {
        case .trace, .debug:
            return .debug
        case .info:
            return .info
        case .notice:
            return .default
        case .warning, .error:
            return .error
        case .fault:
            return .fault
        }
    }
}
