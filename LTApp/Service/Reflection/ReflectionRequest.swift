//
//  LTApp, This code is protected by intellectual property rights.
//


import Foundation

struct AnswerParam: Encodable {
    let questionId: String
    let content: String
    
    enum CodingKeys: String, CodingKey {
        case questionId = "question_id"
        case content = "content"
    }
}

extension Encodable {
    func json() -> [String: any Sendable] {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(self),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: any Sendable] else {
            return [:]
        }
        return dict
    }
}

enum ReflectionRequest: Request {
    case onboardingSentences
    case categories
    case headQuestion(_ categoryId: String)
    case answerQuestion(_ param: AnswerParam)
    
    var endPoint: any EndPoint {
        var path: String = ""
        switch self {
        case .onboardingSentences:
            path += "/onboard"
        case .categories:
            path += "/categories"
        case let .headQuestion(categortId):
            path += "/categories/\(categortId)/head"
        case let .answerQuestion(param):
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

