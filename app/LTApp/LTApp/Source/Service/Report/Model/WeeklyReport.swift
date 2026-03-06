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
    let reportJson: ReportContent
    let icons: [IconData]
}

public struct ReportContent: Sendable {
    let summary: String
    let momentToReveal: String
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
