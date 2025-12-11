//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public struct DayReflectionsDTO: Decodable {
    let date: String
    let reflections: [AnswerDTO]
    
    enum CodingKeys: CodingKey {
        case date
        case reflections
    }
    
    init(date: String, reflections: [AnswerDTO]) {
        self.date = date
        self.reflections = reflections
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.date = try container.decode(String.self, forKey: .date)
        self.reflections = try container.decode([AnswerDTO].self, forKey: .reflections)
    }
}

extension DayReflectionsDTO {
    func toDomain() -> DayReflections {
        let day = AppDateFormatter.yyyymmdd.date(from: date) ?? Date()
        return DayReflections(
            day: day,
            reflections: reflections.map { $0.toDomain() },
        )
    }
}
