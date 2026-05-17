//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//


import Foundation
import LTNetwork

public actor AuthInterceptor: NetworkInterceptor, @unchecked Sendable {
    private weak var tokenProvider: TokenProvider?
    
    init(tokenProvider: TokenProvider? = nil) {
        self.tokenProvider = tokenProvider
    }
    
    public func onRequest(_ request: URLRequest, handler: RequestInterceptorHandler) async -> RequestInterceptorResult {
        var request = request
        if let token = tokenProvider?.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return handler.next(request)
    }
}
