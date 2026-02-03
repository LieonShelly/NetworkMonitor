//
//  LTApp, This code is protected by intellectual property rights.
//


import Foundation

struct CategoryDTO: Decodable {
    var id: String?
    var name: String
    var questions: [QuestionDTO]?
    let imageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case questions
        case imageUrl = "image_url"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try? container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.questions = (try? container.decode([QuestionDTO].self, forKey: .questions))
        self.imageUrl = try? container.decode(String.self, forKey: .imageUrl)
    }
}

extension CategoryDTO {
    func toDomain() -> Category {
        return Category(
            id: id ?? UUID().uuidString,
            name: name,
            questions: (questions ?? []).map { $0.toDomain() },
            imageUrl: imageUrl ?? ""
        )
    }
}
