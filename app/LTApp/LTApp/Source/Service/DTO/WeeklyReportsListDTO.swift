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
    
    enum CodingKeys: String, CodingKey {
        case id
        case week
        case periodStart = "period_start"
        case periodEnd = "period_end"
        case reflectionCount = "reflection_count"
        case readAt = "read_at"
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
        let readAtDate = readAt != nil ? ISO8601DateFormatter().date(from: readAt!) : nil
        
        return WeeklyReportSummary(
            id: id,
            week: week,
            periodStart: periodStartDate,
            periodEnd: periodEndDate,
            reflectionCount: reflectionCount,
            readAt: readAtDate
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
