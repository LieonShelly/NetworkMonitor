//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public struct Answer: Sendable {
    let id: String
    let content: String
    let createAt: Date?
}

public struct DayReflections: Sendable {
    let day: Date
    let reflections: [Answer]
}

public struct ThreadQuestion: Sendable {
    let id: String
    let title: String
    let answers: [Answer]
}


public struct ReflectionSummary: Sendable {
    let daysOver: Int
    let totalAnswers: Int
    let firstAnswerAt: Date
    let lastAnswerAt: Date
}

public struct Pagination: Sendable {
    let limit: Int
    let hasMore: Bool
    let nextCursor: Bool?
}

public struct History: Sendable {
    let summary: ReflectionSummary
    let answers: [Answer]
    let pagination: Pagination
}
