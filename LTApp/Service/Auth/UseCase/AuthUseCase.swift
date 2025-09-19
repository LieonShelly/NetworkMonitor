//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public protocol AuthUseCaseType {
    func execute(authorizationCode: String, identityToken: String) async throws -> User
}

public final class AuthUseCase: AuthUseCaseType {
    private let repository: AuthRepositoryType
    
    public init(repository: AuthRepositoryType) {
        self.repository = repository
    }
    
    public func execute(authorizationCode: String, identityToken: String) async throws -> User {
       try await repository.login(authorizationCode: authorizationCode, identityToken: identityToken)
    }
}

