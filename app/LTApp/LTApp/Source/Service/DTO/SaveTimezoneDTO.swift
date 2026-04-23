//
//  LTApp, This code is protected by intellectual property rights.
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
