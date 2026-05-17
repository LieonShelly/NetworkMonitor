//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation
import LTNetwork

enum NotificationRequest: Request {
    case saveDeviceToken(_ deviceToken: String)
    
    var endPoint: any EndPoint {
        var path: String = "/api"
        switch self {
        case .saveDeviceToken:
            path += "/device-token"
        }
        return DefaultEndPoint.baseURL(path: path)
    }
    
    var method: HttpMethod {
        switch self {
        case .saveDeviceToken:
                .post
        }
    }
    
    var payload: HttpPayload {
        switch self {
        case let .saveDeviceToken(token):
            return .json(body: [
                "deviceToken": token
            ], urlParameter: nil)
        }
    }
}
