//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public struct AnswerDTO: Decodable {
    let id: String
    let content: String
    let createTms: String?
    let createdYmd: String?
    let icon: IconDto?
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case createTms = "created_tms"
        case createdYmd = "created_ymd"
        case icon
    }
}


extension AnswerDTO {
    func toDomain() -> Answer {
        var createTmsDate: Date?
        if let createTms {
            createTmsDate = AppDateFormatter.ymdhsm.date(from: createTms)
        }
        var createYmdDate: Date?
        if let createdYmd {
            createYmdDate = AppDateFormatter.yyyymmdd.date(from: createdYmd)
        }
        return Answer(
            id: id,
            content: content,
            createTms: createTmsDate,
            createYmd: createYmdDate
        )
    }
}


struct HistoryDTO: Decodable {
    let summary: ReflectionSummaryDTO
    let answers: [AnswerDTO]
    let pagination: PaginationDTO
}

public struct ReflectionSummaryDTO: Decodable {
    let daysOver: Int
    let totalAnswers: Int
    let firstAnswerAt: String
    let lastAnswerAt: String
}

public struct PaginationDTO: Decodable {
    let limit: Int?
    let hasMore: Bool?
    let nextCursor: Bool?
}


extension ReflectionSummaryDTO {
    func toDomain() -> ReflectionSummary {
        return ReflectionSummary(
            daysOver: daysOver,
            totalAnswers: totalAnswers,
            firstAnswerAt: AppDateFormatter.ymdhsm.date(from: firstAnswerAt) ?? Date(),
            lastAnswerAt: AppDateFormatter.ymdhsm.date(from: lastAnswerAt) ?? Date()
        )
    }
}

extension PaginationDTO {
    func toDomain() -> Pagination {
        return Pagination(
            limit: limit,
            hasMore: hasMore,
            nextCursor: nextCursor
        )
    }
}

extension HistoryDTO {
    func toDomain() -> History {
        History(
            summary: summary.toDomain(),
            answers: answers.map { $0.toDomain() },
            pagination: pagination.toDomain()
        )
    }
}
