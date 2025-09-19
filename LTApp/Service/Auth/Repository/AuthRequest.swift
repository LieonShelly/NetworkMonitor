//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

enum AuthRequest: Request {
    case login(authorizationCode: String, identityToken: String)
    case refreshToken(_ refreshToken: String)
    
    var endPoint: any EndPoint {
        var path: String = "/api"
        switch self {
        case .login:
            path += "/auth/login"
        case .refreshToken:
            path += "/auth/refresh"
        }
        return DefaultEndPoint.baseURL(path: path)
    }
    
    var method: HttpMethod {
        return .post
    }
    
    var payload: HttpPayload {
        switch self {
        case let .login(authorizationCode, identityToken):
            return .json(body: ["authorizationCode": authorizationCode, "identityToken": identityToken])
        case let .refreshToken(value):
            return .json(body: ["refresh_token": value])
        }
    }
}
