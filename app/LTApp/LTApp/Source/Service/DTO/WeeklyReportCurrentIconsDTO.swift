//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public struct WeeklyReportCurrentIconsDTO: Decodable {
    let minAnswersToGenerateReport: Int
    let periodStart: String?
    let periodEnd: String?
    let readAt: String?
    let icons: [WeeklyReportIconDTO]
    
    enum CodingKeys: String, CodingKey {
        case minAnswersToGenerateReport = "minAnswersToGenerateReport"
        case periodStart = "period_start"
        case periodEnd = "period_end"
        case readAt = "read_at"
        case icons
    }
}

public struct WeeklyReportIconDTO: Decodable {
    let id: String
    let answerId: String
    let createdYmd: String
    let url: String
    let readAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case answerId = "answer_id"
        case createdYmd = "created_ymd"
        case url
        case readAt = "read_at"
    }
}

extension WeeklyReportCurrentIconsDTO {
    func toDomain() -> WeeklyReportCurrentIcons {
        let periodStartDate = periodStart.flatMap { AppDateFormatter.yyyymmdd.date(from: $0) }
        let periodEndDate = periodEnd.flatMap { AppDateFormatter.yyyymmdd.date(from: $0) }
        let readAtDate = readAt.flatMap { AppDateFormatter.iso8601.date(from: $0) }
        
        return WeeklyReportCurrentIcons(
            minAnswersToGenerateReport: minAnswersToGenerateReport,
            periodStart: periodStartDate,
            periodEnd: periodEndDate,
            readAt: readAtDate,
            icons: icons.map { $0.toDomain() }
        )
    }
}

extension WeeklyReportIconDTO {
    func toDomain() -> WeeklyReportIcon {
        let readAtDate = readAt.flatMap { AppDateFormatter.iso8601.date(from: $0) }
        
        return WeeklyReportIcon(
            id: id,
            answerId: answerId,
            createdYmd: createdYmd,
            url: url,
            readAt: readAtDate
        )
    }
}
