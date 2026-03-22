//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public struct WeeklyReportsList: Sendable {
    let reports: [WeeklyReportSummary]
    let pagination: PaginationInfo
}

public struct WeeklyReportSummary: Sendable, Identifiable {
    public let id: String
    let week: String
    let periodStart: Date
    let periodEnd: Date
    let reflectionCount: Int
    let readAt: Date?
    let summary: String
    let icon: ReportIcon
}

public struct PaginationInfo: Sendable {
    let limit: Int
    let hasMore: Bool
    let nextCursor: String?
}
