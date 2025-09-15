//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

enum AuthRequest: Request {
    case login(appleId: String, authToken: String)
    
    var endPoint: any EndPoint {
        var path: String = ""
        switch self {
        case .login:
            path += "/api/auth/login"
        }
        return DefaultEndPoint.baseURL(path: path)
    }
    
    var method: HttpMethod {
        return .post
    }
    
    var payload: HttpPayload {
        switch self {
        case let .login(appleId, authToken):
            return .json(body: ["appleId": appleId, "authToken": authToken], urlParameter: nil)
        }
    }
}
