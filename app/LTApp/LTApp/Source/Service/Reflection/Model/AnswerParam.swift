//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public struct AnswerParam: Encodable, Sendable {
    let questionId: String
    let content: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case questionId = "question_id"
        case content = "content"
        case createdAt = "created_tms"
    }
    
    public init(questionId: String, content: String, createdAt: String) {
        self.questionId = questionId
        self.content = content
        self.createdAt = createdAt
    }
}
