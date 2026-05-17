//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
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
        let readAtDate: Date? = {
            guard let readAt else { return nil }
            return AppDateFormatter.iso8601.date(from: readAt)
        }()
        return WeeklyReportReadResult(
            week: week,
            readAt: readAtDate
        )
    }
}
