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
    
    var endPoint: any EndPoint {
        var path: String = "/api"
        switch self {
        case let .generate(iconId):
            path += "/icon/progress/\(iconId)"
        }
        return DefaultEndPoint.baseURL(path: path)
    }
    
    var method: HttpMethod {
        switch self {
        case .generate:
                .get
        }
    }
    
    var payload: HttpPayload {
        return .empty
    }
}
