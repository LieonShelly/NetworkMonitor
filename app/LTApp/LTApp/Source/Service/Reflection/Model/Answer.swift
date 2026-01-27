//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public struct Answer: Sendable, Equatable, Hashable {
    let id: String
    let content: String
    let createTms: Date?
    let createYmd: Date?
    var icon: IconData?
    var question: Question?
    var uid: UUID = UUID()
    
    public static func == (lhs: Answer, rhs: Answer) -> Bool {
        lhs.id == rhs.id
    }
    
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func copy(with uid: UUID = UUID()) -> Answer {
        return .init(
            id: id,
            content: content,
            createTms: createTms,
            createYmd: createYmd,
            icon: icon,
            question: question,
            uid: uid
        )
    }
}

public struct DayReflections: Sendable {
    let day: Date
    var reflections: [Answer]
}

public struct ThreadQuestion: Sendable {
    let id: String
    let title: String
    let pinned: Bool
    let answers: [Answer]
    let category: Category
    
}

extension ThreadQuestion {
    func toQuestion() -> Question {
        .init(id: id, title: title, pinned: true)
    }
}


public struct ReflectionSummary: Sendable {
    let daysOver: Int
    let totalAnswers: Int
    let firstAnswerAt: Date
    let lastAnswerAt: Date
}

public struct Pagination: Sendable {
    let limit: Int?
    let hasMore: Bool?
    let nextCursor: Bool?
}

public struct History: Sendable {
    let summary: ReflectionSummary
    let answers: [Answer]
    let pagination: Pagination
}
