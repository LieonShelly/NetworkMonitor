//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public struct LoginInfoDTO: Decodable {
    let accessToken: String
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

