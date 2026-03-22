//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public struct WeeklyReportReadResultDTO: Decodable {
    let week: String
    let readAt: String?
    
    enum CodingKeys: String, CodingKey {
        case week
        case readAt = "read_at"
    }
}

extension WeeklyReportReadResultDTO {
    func toDomain() -> WeeklyReportReadResult {
        let readAtDate = readAt != nil ? ISO8601DateFormatter().date(from: readAt!) : nil
        return WeeklyReportReadResult(
            week: week,
            readAt: readAtDate
        )
    }
}
