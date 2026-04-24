//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public protocol AuthUseCaseType: Sendable {
    func execute(authorizationCode: String, identityToken: String) async throws
}

public final class AuthUseCase: AuthUseCaseType, @unchecked Sendable {
    private let repository: AuthRepositoryType
    
    public init(repository: AuthRepositoryType) {
        self.repository = repository
    }
    
    public func execute(authorizationCode: String, identityToken: String) async throws {
       try await repository.login(authorizationCode: authorizationCode, identityToken: identityToken)
    }
}

