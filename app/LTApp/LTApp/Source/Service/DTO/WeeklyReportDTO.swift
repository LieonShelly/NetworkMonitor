//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public struct WeeklyReportDTO: Decodable {
    let id: String
    let week: String
    let periodStart: String
    let periodEnd: String
    let reflectionCount: Int
    let readAt: String?
    let reportJson: ReportContentDTO
    let icons: [IconDto]
    
    enum CodingKeys: String, CodingKey {
        case id
        case week
        case periodStart = "period_start"
        case periodEnd = "period_end"
        case reflectionCount = "reflection_count"
        case readAt = "read_at"
        case reportJson = "report_json"
        case icons
    }
}

public struct ReportContentDTO: Decodable {
    let summary: String
    let gem: GemContentDTO
    let analyticalOverview: [AnalyticalSectionDTO]
}

public struct AnalyticalSectionDTO: Decodable {
    let title: String
    let content: String
}

extension WeeklyReportDTO {
    func toDomain() -> WeeklyReport {
        let periodStartDate = AppDateFormatter.yyyymmdd.date(from: periodStart) ?? Date()
        let periodEndDate = AppDateFormatter.yyyymmdd.date(from: periodEnd) ?? Date()
        let readAtDate: Date? = {
            guard let readAt else { return nil }
            return AppDateFormatter.iso8601.date(from: readAt)
        }()
        
        return WeeklyReport(
            id: id,
            week: week,
            periodStart: periodStartDate,
            periodEnd: periodEndDate,
            reflectionCount: reflectionCount,
            readAt: readAtDate,
            reportJson: reportJson.toDomain(),
            icons: icons.map { $0.toDomain() }
        )
    }
}

extension ReportContentDTO {
    func toDomain() -> ReportContent {
        return ReportContent(
            summary: summary,
            gem: gem.toDomain(),
            analyticalOverview: analyticalOverview.map { $0.toDomain() }
        )
    }
}

extension AnalyticalSectionDTO {
    func toDomain() -> AnalyticalSection {
        return AnalyticalSection(
            title: title,
            content: content
        )
    }
}



public struct GemContentDTO: Decodable {
    let scene: String
    let evidence: String
    let insight: String
    
    func toDomain() -> GemContent {
        return GemContent(
            scene: scene,
            evidence: evidence,
            insight: insight
        )
    }
}
