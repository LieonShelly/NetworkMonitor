//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public struct UserDTO: Decodable {
    let accessToken: String
    let refreshToken: String
    let userInfo: UserInfoDTO
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case userInfo = "user"
    }
}

public struct UserInfoDTO: Decodable {
    let id: String
    let email: String
}

public extension UserDTO {
    func toDomain() -> User {
        return User(
            id: userInfo.id,
            email: ""
        )
    }
}
