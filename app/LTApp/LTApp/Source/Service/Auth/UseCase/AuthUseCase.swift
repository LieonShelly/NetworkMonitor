//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation

public protocol AuthUseCaseType: Sendable {
    func execute(authorizationCode: String, identityToken: String) async throws
    func executeGoogleLogin(idToken: String) async throws
    func logout() async throws
}

public final class AuthUseCase: AuthUseCaseType, @unchecked Sendable {
    private let repository: AuthRepositoryType
    
    public init(repository: AuthRepositoryType) {
        self.repository = repository
    }
    
    public func execute(authorizationCode: String, identityToken: String) async throws {
       try await repository.login(authorizationCode: authorizationCode, identityToken: identityToken)
    }
    
    public func executeGoogleLogin(idToken: String) async throws {
        try await repository.googleLogin(idToken: idToken)
    }
    
    public func logout() async throws {
        try await repository.logout()
    }
}
