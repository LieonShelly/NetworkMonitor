//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public struct WeeklyReport: Sendable {
    let id: String
    let week: String
    let periodStart: Date
    let periodEnd: Date
    let reflectionCount: Int
    let readAt: Date?
    let reportJson: ReportContent
    let icons: [IconData]
    let count: ReportCount?
}


public struct GemIcon: Sendable {
    let id: String
    let url: String
}

public struct GemContent: Sendable {
    let icon: GemIcon?
    let insight: String
    let evidence: String
    let answerId: String?
}


public struct ReportContent: Sendable {
    let summary: String?
    let glance: String?
    let gem: GemContent
    let reminders: [String]
    let analyticalOverview: [AnalyticalSection]
}

public struct AnalyticalSection: Sendable {
    let id: UUID = UUID()
    let title: String
    let content: String
}

public struct ReportIcon: Sendable, Identifiable {
    public let id: String
    let url: String
}

public struct ReportCount: Sendable {
    let categories: [ReportCategoryCount]
    let total: Int
}

public struct ReportCategoryCount: Sendable, Identifiable {
    public let id: String
    let name: String
    let url: String
    let count: Int
}
