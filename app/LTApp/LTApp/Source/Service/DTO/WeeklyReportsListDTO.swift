//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public struct WeeklyReportsListDTO: Decodable {
    let reports: [WeeklyReportSummaryDTO]
    let pagination: PaginationInfoDTO
}

public struct WeeklyReportSummaryDTO: Decodable {
    let id: String
    let week: String
    let periodStart: String
    let periodEnd: String
    let reflectionCount: Int
    let readAt: String?
    let summary: String
    let icon: ReportIconDTO
    
    enum CodingKeys: String, CodingKey {
        case id
        case week
        case periodStart = "period_start"
        case periodEnd = "period_end"
        case reflectionCount = "reflection_count"
        case readAt = "read_at"
        case summary
        case icon
    }
}

public struct PaginationInfoDTO: Decodable {
    let limit: Int
    let hasMore: Bool
    let nextCursor: String?
}

extension WeeklyReportsListDTO {
    func toDomain() -> WeeklyReportsList {
        return WeeklyReportsList(
            reports: reports.map { $0.toDomain() },
            pagination: pagination.toDomain()
        )
    }
}

extension WeeklyReportSummaryDTO {
    func toDomain() -> WeeklyReportSummary {
        let periodStartDate = AppDateFormatter.yyyymmdd.date(from: periodStart) ?? Date()
        let periodEndDate = AppDateFormatter.yyyymmdd.date(from: periodEnd) ?? Date()
        let readAtDate: Date? = {
            guard let readAt else { return nil }
            return AppDateFormatter.iso8601.date(from: readAt)
        }()
        
        return WeeklyReportSummary(
            id: id,
            week: week,
            periodStart: periodStartDate,
            periodEnd: periodEndDate,
            reflectionCount: reflectionCount,
            readAt: readAtDate,
            summary: summary,
            icon: icon.toDomain()
        )
    }
}

extension PaginationInfoDTO {
    func toDomain() -> PaginationInfo {
        return PaginationInfo(
            limit: limit,
            hasMore: hasMore,
            nextCursor: nextCursor
        )
    }
}

struct ReportIconDTO: Decodable {
    let id: String
    let url: String
    
    func toDomain() -> ReportIcon {
        return ReportIcon(
            id: id,
            url: url
        )
    }
}
