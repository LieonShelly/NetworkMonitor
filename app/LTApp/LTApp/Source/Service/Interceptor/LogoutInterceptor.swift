//
//  LTApp, This code is protected by intellectual property rights.
//

import Combine
import Foundation
import LTNetwork

public class LogoutInterceptor: NetworkInterceptor, TokenExpirePublihser, @unchecked Sendable {
    private weak var tokenProvider: TokenProvider?
    private var tokenExpiredSubject: PassthroughSubject<Void, Never>
    
    public var expired: AnyPublisher<Void, Never> {
        tokenExpiredSubject.eraseToAnyPublisher()
    }
    
    public init(tokenProvider: TokenProvider?,) {
        self.tokenProvider = tokenProvider
        tokenExpiredSubject = .init()
    }
    
    public func adapt(_ request: URLRequest) async throws -> URLRequest {
        return request
    }
    
    public func shouldRetry(_ request: URLRequest, response: URLResponse?) async throws -> Bool {
        return false
    }
    
    public func abort(_ request: URLRequest, response: URLResponse?) async throws -> Bool {
        tokenProvider?.clear()
        tokenExpiredSubject.send()
        return true
    }
}
