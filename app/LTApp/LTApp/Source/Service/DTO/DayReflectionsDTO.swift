//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public struct DayReflectionsDTO: Decodable {
    let date: String
    let reflections: [AnswerDTO]
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
