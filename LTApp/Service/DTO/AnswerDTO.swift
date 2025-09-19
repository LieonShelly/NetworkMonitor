//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public struct AnswerDTO: Decodable {
    let id: String
    let content: String
}


extension AnswerDTO {
    func toDomain() -> Answer {
        return Answer(
            id: id,
            content: content
        )
    }
}

