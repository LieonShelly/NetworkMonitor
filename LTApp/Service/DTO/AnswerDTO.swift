//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public struct AnswerDTO: Decodable {
    let id: String
    let content: String
}

public struct DayReflectionsDTO: Decodable {
    let date: String
    let reflections: [AnswerDTO]
}

extension AnswerDTO {
    func toDomain() -> Answer {
        return Answer(
            id: id,
            content: content
        )
    }
}

extension DayReflectionsDTO {
    func toDomain() -> DayReflections {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-DD"
        formatter.timeZone = .current
        let day = formatter.date(from: date) ?? Date()
        return DayReflections(
            day: day,
            reflections: reflections.map { $0.toDomain() }
        )
    }
}
