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


struct UserInfoDTO: Decodable {
    let qodStrategy: String
    let lastLoginAt: String?
    let hasPinnedQuestion: Bool
    let email: String?
    
    enum CodingKeys: String, CodingKey {
        case qodStrategy = "qod_strategy"
        case lastLoginAt = "last_login_at"
        case hasPinnedQuestion = "has_pinned_question"
        case email = "email"
    }
}


extension UserInfoDTO {
    func toDomain() -> User {
        let lastLoginAt = ISO8601DateFormatter().date(from: lastLoginAt ?? "") ?? Date()
        return  User(
            qodStrategy: .init(rawValue: qodStrategy) ?? .random,
            lastLoginAt: lastLoginAt,
            hasPinnedQuestion: hasPinnedQuestion,
            email: email
        )
    }
}
