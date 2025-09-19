//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public struct QuestionDTO: Decodable {
    var id: String
    var title: String
}


public extension QuestionDTO {
    func toDomain() -> Question {
        return Question(
            id: id,
            title: title
        )
    }
}
