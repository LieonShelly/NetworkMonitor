//
//  UserSettingRequest.swift
//  LTApp
//
//  Created by Renjun Li on 2026/2/5.
//

import Foundation
import LTNetwork

enum UserFlowRequest: Request, @unchecked Sendable{
    case userInfo
    case qodStrategyOptions
    case updateQodStrategy(_ strategy: String)
    
    var endPoint: any EndPoint {
        var path: String = "/api"
        switch self {
        case .userInfo:
            path += "/me"
        case .updateQodStrategy:
            path += "/qod-strategy"
        case .qodStrategyOptions:
            path += "/qod-strategy-options"
        }
        return DefaultEndPoint.baseURL(path: path)
    }
    
    var method: HttpMethod {
        switch self {
        case .userInfo:
            return .get
        case .updateQodStrategy:
            return .post
        case .qodStrategyOptions:
            return .get
        }
    }
    
    var payload: HttpPayload {
        switch self {
        case .userInfo, .qodStrategyOptions:
            return .empty
        case let .updateQodStrategy(strategy):
            return .json(body: ["qod_strategy": strategy], urlParameter: nil)
        }
    }
}
