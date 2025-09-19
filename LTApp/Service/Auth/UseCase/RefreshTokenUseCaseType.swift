//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public protocol RefreshTokenUseCaseType: Sendable {
    func execute() async throws
}

public final class RefreshTokenUseCase: RefreshTokenUseCaseType, @unchecked Sendable {
    private let repository: SessionDataRepositoryType
    
    public init(repository: SessionDataRepositoryType) {
        self.repository = repository
    }
    
    public func execute() async throws {
       try await repository.refreshToken()
    }
}
