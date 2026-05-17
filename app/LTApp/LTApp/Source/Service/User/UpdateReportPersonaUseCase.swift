//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation

public protocol UpdateReportPersonaUseCaseType: Sendable {
    func execute(personaId: String) async throws -> UpdateReportPersonaResult
}

public class UpdateReportPersonaUseCase: UpdateReportPersonaUseCaseType, @unchecked Sendable {
    private let repository: any UserFlowRepositoryType
    
    public init(repository: any UserFlowRepositoryType) {
        self.repository = repository
    }
    
    public func execute(personaId: String) async throws -> UpdateReportPersonaResult {
        try await repository.updateReportPersona(personaId)
    }
}
