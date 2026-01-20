//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

struct ThreadQuestionDTO: Decodable {
    let id: String
    let title: String
    let pinned: Bool
    let answers: [AnswerDTO]
}

extension ThreadQuestionDTO {
    func toDomain() -> ThreadQuestion {
        return ThreadQuestion(
            id: id,
            title: title,
            pinned: pinned,
            answers: answers.map { $0.toDomain() }
        )
    }
}
