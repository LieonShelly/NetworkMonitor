//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation
import LTNetwork

public protocol AuthRepositoryType {
    func login(authorizationCode: String, identityToken: String) async throws -> User
}

public final class AuthRepository: AuthRepositoryType {
    private let apiClient: ApiClient
    private let authTokenProvider: any TokenProvider
    
    public init(apiClient: ApiClient, authTokenProvider: any TokenProvider) {
        self.apiClient = apiClient
        self.authTokenProvider = authTokenProvider
    }
    
    public func login(authorizationCode: String, identityToken: String) async throws -> User {
        let request = AuthRequest.login(authorizationCode: authorizationCode, identityToken: identityToken)
        let response = try await apiClient.sendRequest(request)
        let userDto: UniversalResponse<UserDTO> = try response.parseJson()
        try authTokenProvider.updateTokens(
            accessToken: userDto.data.accessToken,
            refreshToken: userDto.data.refreshToken
        )
        return userDto.data.toDomain()
    }
    
}
