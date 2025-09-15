//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public protocol AuthUseCaseType {
    func execute(appleId: String, authToken: String) async throws -> User
}

public final class AuthUseCase: AuthUseCaseType {
    private let repository: AuthRepositoryType
    
    init(repository: AuthRepositoryType) {
        self.repository = repository
    }
    
    public func execute(appleId: String, authToken: String) async throws -> User {
       try await repository.login(appleId: appleId, authToken: authToken)
    }
}
