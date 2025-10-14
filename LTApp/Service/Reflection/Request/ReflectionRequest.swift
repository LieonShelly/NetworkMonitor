//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

enum ReflectionRequest: Request {
    case onboardingSentences
    case categories
    case headQuestion(_ categoryId: String)
    case answerQuestion(_ param: AnswerParam)
    case calendar(startDate: String, endDate: String)
    case thread
    case questionList
    
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
        case .calendar:
            path += "/calendar-view"
        case .thread:
            path += "/thread-view"
        case .questionList:
            path += "/questions"
        }
        return DefaultEndPoint.baseURL(path: path)
    }
    
    var method: HttpMethod {
        switch self {
        case .onboardingSentences,
                .categories,
                .headQuestion,
                .calendar,
                .thread,
                .questionList:
                .get
        case .answerQuestion:
                .post
        }
    }
    
    var payload: HttpPayload {
        switch self {
        case let .answerQuestion(param):
            return .json(body: param.json(), urlParameter: nil)
        case let .calendar(startDate: startDate, endDate: endDate):
            return .urlEncoding([
                ("start", startDate),
                ("end", endDate)
            ])
        default:
            return .empty
        }
    }
}
