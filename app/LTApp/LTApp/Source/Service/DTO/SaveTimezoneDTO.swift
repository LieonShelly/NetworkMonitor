//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation

public struct SaveTimezoneDTO: Decodable {
    let timezone: String
}

extension SaveTimezoneDTO {
    func toDomain() -> SaveTimezoneResult {
        return SaveTimezoneResult(timezone: timezone)
    }
}
