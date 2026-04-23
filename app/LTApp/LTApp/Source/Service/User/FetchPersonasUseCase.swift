//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public protocol FetchPersonasUseCaseType: Sendable {
    func execute() async throws -> [PersonaOption]
}

public class FetchPersonasUseCase: FetchPersonasUseCaseType, @unchecked Sendable {
    private let repository: any UserFlowRepositoryType
    
    public init(repository: any UserFlowRepositoryType) {
        self.repository = repository
    }
    
    public func execute() async throws -> [PersonaOption] {
        try await repository.fetchPersonas()
    }
}
