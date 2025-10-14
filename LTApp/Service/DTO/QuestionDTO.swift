//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public struct QuestionDTO: Decodable {
    var id: String
    var title: String
    let pinned: Bool
    
    enum CodingKeys: CodingKey {
        case id
        case title
        case pinned
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.pinned = (try? container.decode(Bool.self, forKey: .pinned)) ?? false
    }
}

public extension QuestionDTO {
    func toDomain() -> Question {
        return Question(
            id: id,
            title: title,
            pinned: pinned
        )
    }
}
