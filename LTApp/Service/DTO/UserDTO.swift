//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public struct UserDTO: Decodable {
    let userId: String
    let displayName: String
    let token: String
    let refreshToken: String
    let expiresAt: TimeInterval
}

public extension UserDTO {
    func toDomain() -> User {
        return User(
            userId: userId,
            fullName: displayName,
            email: ""
        )
    }
}
