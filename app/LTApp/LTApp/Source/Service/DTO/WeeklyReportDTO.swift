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
    let count: ReportCountDTO?
    
    enum CodingKeys: String, CodingKey {
        case id
        case week
        case periodStart = "period_start"
        case periodEnd = "period_end"
        case reflectionCount = "reflection_count"
        case readAt = "read_at"
        case reportJson = "report_json"
        case icons
        case count
    }
}

public struct ReportCountDTO: Decodable {
    let categories: [ReportCategoryCountDTO]
    let total: Int
}

public struct ReportCategoryCountDTO: Decodable {
    let id: String
    let name: String
    let url: String
    let count: Int
}

public struct ReportContentDTO: Decodable {
    let summary: String
    let glance: String?
    let gem: GemContentDTO
    let reminders: [String]?
    let analyticalOverview: [AnalyticalSectionDTO]?
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
            icons: icons.map { $0.toDomain() },
            count: count?.toDomain()
        )
    }
}

extension ReportContentDTO {
    func toDomain() -> ReportContent {
        return ReportContent(
            summary: summary,
            glance: glance,
            gem: gem.toDomain(),
            reminders: reminders ?? [],
            analyticalOverview: (analyticalOverview ?? []).map { $0.toDomain() }
        )
    }
}

extension ReportCountDTO {
    func toDomain() -> ReportCount {
        return ReportCount(
            categories: categories.map { $0.toDomain() },
            total: total
        )
    }
}

extension ReportCategoryCountDTO {
    func toDomain() -> ReportCategoryCount {
        return ReportCategoryCount(id: id, name: name, url: url, count: count)
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
    let icon: GemIconDTO?
    let insight: String
    let evidence: String
    let answerId: String?
    
    enum CodingKeys: String, CodingKey {
        case icon, insight, evidence
        case answerId = "answer_id"
    }
    
    func toDomain() -> GemContent {
        return GemContent(
            icon: icon.map { GemIcon(id: $0.id, url: $0.url) },
            insight: insight,
            evidence: evidence,
            answerId: answerId
        )
    }
}

public struct GemIconDTO: Decodable {
    let id: String
    let url: String
}
