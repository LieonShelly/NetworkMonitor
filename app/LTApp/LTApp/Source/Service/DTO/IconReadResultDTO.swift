//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation

public struct IconReadResultDTO: Decodable {
    let id: String
    let readAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case readAt = "read_at"
    }
}

extension IconReadResultDTO {
    func toDomain() -> IconReadResult {
        let readAtDate: Date? = {
            guard let readAt else { return nil }
            return AppDateFormatter.iso8601.date(from: readAt)
        }()
        return IconReadResult(id: id, readAt: readAtDate)
    }
}
