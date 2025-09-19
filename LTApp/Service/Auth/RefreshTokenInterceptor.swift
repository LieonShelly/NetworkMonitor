//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

actor RefreshTokenInterceptor: NetworkInterceptor, @unchecked Sendable {
    private weak var tokenProvider: TokenProvider?
    private let service: any AppDataWithoutAuthorizationServicefull
    
    init(tokenProvider: TokenProvider?, service: any AppDataWithoutAuthorizationServicefull) {
        self.tokenProvider = tokenProvider
        self.service = service
    }
    
    func adapt(_ request: URLRequest) async throws -> URLRequest {
        return request
    }
    
    func shouldRetry(_ request: URLRequest, response: URLResponse?) async throws -> Bool {
        guard let response = response as? HTTPURLResponse, response.statusCode == 401 else {
            return false
        }
        try await refreshTokenIfNeeded()
        return true
    }
    
    private func refreshTokenIfNeeded() async throws {
        guard let refreshToken = tokenProvider?.refreshToken,
              let token = tokenProvider?.accessToken else {
            tokenProvider?.clear()
            throw AppNetworkError.httpError(statusCode: .unauthorized, body: nil)
        }
        try await service.refreshTokenUseCase.execute()
    }
}
