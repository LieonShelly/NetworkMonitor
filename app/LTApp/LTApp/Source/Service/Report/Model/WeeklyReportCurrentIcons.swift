//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public struct WeeklyReportCurrentIcons: Sendable {
    let minAnswersToGenerateReport: Int
    let periodStart: Date?
    let periodEnd: Date?
    let readAt: Date?
    let icons: [WeeklyReportIcon]
}

public struct WeeklyReportIcon: Sendable, Identifiable {
    public let id: String
    let answerId: String
    let createdYmd: String
    let url: String
    let readAt: Date?
}
