//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

struct ThreadQuestionDTO: Decodable {
    let id: String
    let title: String
    let answers: [AnswerDTO]
}

extension ThreadQuestionDTO {
    func toDomain() -> ThreadQuestion {
        return ThreadQuestion(
            id: UUID().uuidString,
            title: title,
            answers: answers.map { $0.toDomain() }
        )
    }
}
