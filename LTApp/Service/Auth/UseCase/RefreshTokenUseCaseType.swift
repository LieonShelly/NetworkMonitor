//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public protocol RefreshTokenUseCaseType {
    func execute() async throws
}

public final class RefreshTokenUseCase: RefreshTokenUseCaseType {
    private let repository: AuthRepositoryType
    
    public init(repository: AuthRepositoryType) {
        self.repository = repository
    }
    
    public func execute() async throws {
       try await repository.refreshToken()
    }
}
