//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import OSLog

public enum LTLogLevel: Int, CaseIterable, Codable, Comparable, Hashable, Sendable {
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
    public var name: String {
        switch self {
        case .trace:
            return "trace"
        case .debug:
            return "debug"
        case .info:
            return "info"
        case .notice:
            return "notice"
        case .warning:
            return "warning"
        case .error:
            return "error"
        case .fault:
            return "fault"
        }
    }

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
