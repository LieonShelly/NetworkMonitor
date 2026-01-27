//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation
import LTNetwork

enum ReflectionRequest: Request {
    case onboardingSentences
    case categories
    case headQuestion(_ categoryId: String)
    case answerQuestion(_ param: AnswerParam)
    case calendar(startDate: String, endDate: String)
    case thread
    case questionList
    case pinQuestion(id: String, pinned: Bool)
    case answers(questionId: String, limit: Int? = nil, cursor: Int? = nil)
    case questionsOfToday
    case deleteAnswer(answerId: String)
    
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
        case .pinQuestion:
            path += "/questions/pin"
        case .answers:
            path += "/answers"
        case .questionsOfToday:
            path += "/questions-of-the-day"
        case let .deleteAnswer(answerId):
            path += "/answers/\(answerId)"
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
                .questionList,
                .questionsOfToday,
                .answers:
                .get
        case .answerQuestion, .pinQuestion:
                .post
        case .deleteAnswer:
                .delete
        }
    }
    
    var payload: HttpPayload {
        switch self {
        case let .answerQuestion(param):
            return .json(body: param.json(), urlParameter: nil)
        case let .pinQuestion(id, pinned):
            return .json(
                body: [
                    "question_id": id,
                    "pinned": pinned
                ],
                urlParameter: nil
            )
        case let .calendar(startDate: startDate, endDate: endDate):
            return .urlEncoding([
                ("start", startDate),
                ("end", endDate)
            ])
        case let .answers(questionId, limit, cursor):
            var body: [String: String] = ["question_id": questionId]
            if let limit {
                body["limit"] = "\(limit)"
            }
            if let cursor {
                body["cursor"] = "\(cursor)"
            }
            return .urlEncoding(body.map {($0.key, $0.value) })
        default:
            return .empty
        }
    }
}
