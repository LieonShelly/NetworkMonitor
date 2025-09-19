//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public protocol AuthRepositoryType {
    func login(authorizationCode: String, identityToken: String) async throws -> User
    func refreshToken() async throws
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
        return userDto.data.toDomain()
    }
    
    public func refreshToken() async throws {
        guard let refreshToken = authTokenProvider.refreshToken else {
            throw AppNetworkError.httpError(statusCode: .unauthorized, body: nil)
        }
        let request = AuthRequest.refreshToken(refreshToken)
        let response = try await apiClient.sendRequest(request)
        let userDto: UniversalResponse<UserDTO> = try response.parseJson()
        authTokenProvider.updateTokens(accessToken: userDto.data.accessToken, refreshToken: userDto.data.refreshToken)
    }
}
