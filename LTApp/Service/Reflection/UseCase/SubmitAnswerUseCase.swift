//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public protocol SubmitAnswerUseType: Sendable {
    func execute(_ param: AnswerParam) async throws -> Answer
}


public class SubmitAnswerUseCase: SubmitAnswerUseType, @unchecked Sendable {
    private let repository: any ReflectionRepositoryType
    
    init(repository: any ReflectionRepositoryType) {
        self.repository = repository
    }
    
    public func execute(_ param: AnswerParam) async throws -> Answer {
      try await repository.submitAnswer(param)
    }
}
