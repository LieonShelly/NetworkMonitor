//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

actor RefreshTokenInterceptor: NetworkInterceptor, @unchecked Sendable {
    private weak var tokenProvider: TokenProvider?
    private let service: any AppDataWithoutAuthorizationServicefull
    private var requestsPool: [URLRequest] = []
    
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
        guard !requestsPool.contains(request) else {
            return false
        }
        do {
            try await refreshTokenIfNeeded()
            requestsPool.append(request)
            return true
        } catch {
            return false
        }
    }
    
    private func refreshTokenIfNeeded() async throws {
        try await service.refreshTokenUseCase.execute()
    }
}
