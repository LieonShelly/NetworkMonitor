//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public struct AnswerParam: Encodable {
    let questionId: String
    let content: String
    
    enum CodingKeys: String, CodingKey {
        case questionId = "question_id"
        case content = "content"
    }
    
    public init(questionId: String, content: String) {
        self.questionId = questionId
        self.content = content
    }
}
