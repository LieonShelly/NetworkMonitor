//
//  LTApp, This code is protected by intellectual property rights.
//


import Foundation

public actor AuthInterceptor: NetworkInterceptor, @unchecked Sendable {
    private weak var tokenProvider: TokenProvider?
    
    init(tokenProvider: TokenProvider? = nil) {
        self.tokenProvider = tokenProvider
    }
    
    public func adapt(_ request: URLRequest) async throws -> URLRequest {
        var request = request
        if let token = tokenProvider?.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    public func shouldRetry(_ request: URLRequest, response: URLResponse?) async throws -> Bool {
        return false
    }
}
