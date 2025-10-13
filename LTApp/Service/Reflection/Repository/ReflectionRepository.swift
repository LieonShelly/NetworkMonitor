//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public protocol ReflectionRepositoryType {
    func fetchOnboardingSentence() async throws -> OnboardingSentence
    
    func fetchCategories() async throws -> [Category]
    
    func fetchHeadQuestion(_ categorId: String) async throws -> Question
    
    func submitAnswer(_ param: AnswerParam) async throws -> Answer
    
    func fetchCalendarReflections(startMonth: Date, endMonth: Date) async throws -> [DayReflections]
}

public final class ReflectionRepository: ReflectionRepositoryType {
    private let apiClient: ApiClient
    
    public init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    public func fetchOnboardingSentence() async throws -> OnboardingSentence {
        let request = ReflectionRequest.onboardingSentences
        let response = try await apiClient.sendRequest(request)
        let dto: UniversalResponse<OnboardingSentenceDTO> = try response.parseJson()
        return dto.data.toDomain()
    }
    
    public func fetchCategories() async throws -> [Category] {
        let request = ReflectionRequest.categories
        let response = try await apiClient.sendRequest(request)
        let dto: UniversalResponse<[CategoryDTO]> = try response.parseJson()
        return dto.data.map { $0.toDomain() }
    }
    
    public func fetchHeadQuestion(_ categorId: String) async throws -> Question {
        let request = ReflectionRequest.headQuestion(categorId)
        let response = try await apiClient.sendRequest(request)
        let dto: UniversalResponse<QuestionDTO> = try response.parseJson()
        return dto.data.toDomain()
    }
    
    public func submitAnswer(_ param: AnswerParam) async throws -> Answer {
        let request = ReflectionRequest.answerQuestion(param)
        let response = try await apiClient.sendRequest(request)
        let dto: UniversalResponse<AnswerDTO> = try response.parseJson()
        return dto.data.toDomain()
    }
    
    public func fetchCalendarReflections(startMonth: Date, endMonth: Date) async throws -> [DayReflections] {
        let request = ReflectionRequest.calendar(
            startDate: startMonth.yyyymmdd,
            endDate: endMonth.yyyymmdd
        )
        let response = try await apiClient.sendRequest(request)
        let dto: UniversalResponse<[DayReflectionsDTO]> = try response.parseJson()
        return dto.data.map { $0.toDomain() }
    }
}


