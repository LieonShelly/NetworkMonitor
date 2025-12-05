//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public struct DayReflectionsDTO: Decodable {
    let date: String
    let question: QuestionDTO
    let reflections: [AnswerDTO]
    
    enum CodingKeys: CodingKey {
        case date
        case question
        case reflections
    }
    
    init(date: String, question: QuestionDTO, reflections: [AnswerDTO]) {
        self.date = date
        self.question = .init(id: UUID().uuidString, title: "What was one thing you saw that was delightfully absurd or silly")
        self.reflections = reflections
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.date = try container.decode(String.self, forKey: .date)
        self.question = .init(id: UUID().uuidString, title: "What was one thing you saw that was delightfully absurd or silly")
        self.reflections = try container.decode([AnswerDTO].self, forKey: .reflections)
    }
}

extension DayReflectionsDTO {
    func toDomain() -> DayReflections {
        let day = AppDateFormatter.yyyymmdd.date(from: date) ?? Date()
        return DayReflections(
            day: day,
            question: question.toDomain(),
            reflections: reflections.map { $0.toDomain() },
        )
    }
}
