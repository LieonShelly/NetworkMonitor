//
//  LTApp, This code is protected by intellectual property rights.
//


import Foundation

actor AuthInterceptor: NetworkInterceptor {
    private weak var tokenProvider: TokenProvider?
    
    init(tokenProvider: TokenProvider? = nil) {
        self.tokenProvider = tokenProvider
    }
    
    func adapt(_ request: URLRequest) async throws -> URLRequest {
        var request = request
        if let token = tokenProvider?.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    func shouldRetry(_ request: URLRequest, data: Data?, response: URLResponse?, error: (any Error)?) async throws -> Bool {
        return false
    }
}
