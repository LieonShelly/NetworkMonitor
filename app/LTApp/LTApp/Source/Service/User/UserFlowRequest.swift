//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation
import LTNetwork

enum UserFlowRequest: Request, @unchecked Sendable {
    case userInfo
    case updateNickname(_ nickname: String?)
    case qodStrategyOptions
    case updateQodStrategy(_ strategy: String)
    case saveTimezone(_ timestamp: String)
    case fetchReminder
    case updateReminder(_ slot: String?)
    case fetchPersonas
    case updateReportPersona(_ personaId: String)
    
    var endPoint: any EndPoint {
        var path: String = "/api"
        switch self {
        case .userInfo, .updateNickname:
            path += "/me"
        case .updateQodStrategy:
            path += "/qod-strategy"
        case .qodStrategyOptions:
            path += "/qod-strategy-options"
        case .saveTimezone:
            path += "/timezone"
        case .fetchReminder, .updateReminder:
            path += "/me/reminder"
        case .fetchPersonas:
            path += "/ai-insights/personas"
        case .updateReportPersona:
            path += "/ai-insights/report-persona"
        }
        return DefaultEndPoint.baseURL(path: path)
    }
    
    var method: HttpMethod {
        switch self {
        case .userInfo, .qodStrategyOptions, .fetchReminder, .fetchPersonas:
            return .get
        case .updateNickname, .updateQodStrategy, .saveTimezone, .updateReminder, .updateReportPersona:
            return .post
        }
    }
    
    var payload: HttpPayload {
        switch self {
        case .userInfo, .qodStrategyOptions, .fetchReminder, .fetchPersonas:
            return .empty
        case let .updateQodStrategy(strategy):
            return .json(body: ["qod_strategy": strategy], urlParameter: nil)
        case let .saveTimezone(timestamp):
            return .json(body: ["timestamp": timestamp], urlParameter: nil)
        case let .updateNickname(nickname):
            if let nickname {
                return .json(body: ["nickname": nickname], urlParameter: nil)
            }
            return .json(body: ["nickname": NSNull()], urlParameter: nil)
        case let .updateReminder(slot):
            if let slot {
                return .json(body: ["slot": slot], urlParameter: nil)
            }
            return .json(body: ["slot": NSNull()], urlParameter: nil)
        case let .updateReportPersona(personaId):
            return .json(body: ["report_persona_id": personaId], urlParameter: nil)
        }
    }
}
