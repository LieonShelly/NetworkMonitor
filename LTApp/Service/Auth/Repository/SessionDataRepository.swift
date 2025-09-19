//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public protocol SessionDataRepositoryType {
    func refreshToken() async throws

}

public final class SessionDataRepository: SessionDataRepositoryType {
    private let apiClient: ApiClient
    private let authTokenProvider: any TokenProvider
    
    public init(apiClient: ApiClient, authTokenProvider: any TokenProvider) {
        self.apiClient = apiClient
        self.authTokenProvider = authTokenProvider
    }
    
    public func refreshToken() async throws {
        guard let refreshToken = authTokenProvider.refreshToken else {
            throw AppNetworkError.httpError(statusCode: .unauthorized, body: nil)
        }
        let request = AuthRequest.refreshToken(refreshToken)
        let response = try await apiClient.sendRequest(request)
        let userDto: UniversalResponse<UserDTO> = try response.parseJson()
        try authTokenProvider.updateTokens(
            accessToken: userDto.data.accessToken,
            refreshToken: userDto.data.refreshToken
        )
    }
}
