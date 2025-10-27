//
//  LTApp, This code is protected by intellectual property rights.
//


import Foundation

struct CategoryDTO: Decodable {
    var id: String
    var name: String
    var questions: [QuestionDTO]
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case questions
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.questions = (try? container.decode([QuestionDTO].self, forKey: .questions)) ?? []
    }
}

extension CategoryDTO {
    func toDomain() -> Category {
        return Category(id: id, name: name, questions: questions.map { $0.toDomain()})
    }
}
