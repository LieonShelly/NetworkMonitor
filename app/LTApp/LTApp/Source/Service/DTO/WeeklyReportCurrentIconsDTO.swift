//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public struct WeeklyReportCurrentIconsDTO: Decodable {
    let minAnswersToGenerateReport: Int
    let icons: [WeeklyReportIconDTO]
    
    enum CodingKeys: String, CodingKey {
        case minAnswersToGenerateReport = "minAnswersToGenerateReport"
        case icons
    }
}

public struct WeeklyReportIconDTO: Decodable {
    let id: String
    let answerId: String
    let createdYmd: String
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case answerId = "answer_id"
        case createdYmd = "created_ymd"
        case url
    }
}

extension WeeklyReportCurrentIconsDTO {
    func toDomain() -> WeeklyReportCurrentIcons {
        return WeeklyReportCurrentIcons(
            minAnswersToGenerateReport: minAnswersToGenerateReport,
            icons: icons.map { $0.toDomain() }
        )
    }
}

extension WeeklyReportIconDTO {
    func toDomain() -> WeeklyReportIcon {
        return WeeklyReportIcon(
            id: id,
            answerId: answerId,
            createdYmd: createdYmd,
            url: url
        )
    }
}
