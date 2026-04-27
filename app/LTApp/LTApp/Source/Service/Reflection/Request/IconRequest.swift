//
//  IconRequest.swift
//  LTApp
//
//  Created by Renjun Li on 2025/12/1.
//

import Foundation
import LTNetwork


enum IconRequest: Request {
    case generate(_ iconId: String)
    case markRead(_ iconId: String)
    
    var endPoint: any EndPoint {
        var path: String = "/api"
        switch self {
        case let .generate(iconId):
            path += "/icon/progress/\(iconId)"
        case let .markRead(iconId):
            path += "/answers/icons/\(iconId)/read"
        }
        return DefaultEndPoint.baseURL(path: path)
    }
    
    var method: HttpMethod {
        switch self {
        case .generate:
                .get
        case .markRead:
                .post
        }
    }
    
    var payload: HttpPayload {
        return .empty
    }
}
