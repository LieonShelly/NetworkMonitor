//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

enum ReflectionRequest: Request {
    case onboardingSentences
    case categories
    case headQuestion(_ categoryId: String)
    case answerQuestion(_ param: AnswerParam)
    
    var endPoint: any EndPoint {
        var path: String = "/api"
        switch self {
        case .onboardingSentences:
            path += "/onboard"
        case .categories:
            path += "/categories"
        case let .headQuestion(categortId):
            path += "/categories/\(categortId)/head"
        case .answerQuestion:
            path += "/answers"
        }
        return DefaultEndPoint.baseURL(path: path)
    }
    
    var method: HttpMethod {
        switch self {
        case .onboardingSentences:
                .get
        case .categories:
                .get
        case .headQuestion:
                .get
        case .answerQuestion:
                .post
        }
    }
    
    var payload: HttpPayload {
        switch self {
        case let .answerQuestion(param):
            return .json(body: param.json(), urlParameter: nil)
        default:
            return .empty
        }
    }
}
