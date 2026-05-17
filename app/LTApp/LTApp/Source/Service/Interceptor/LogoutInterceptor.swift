//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
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
    
    public func onError(_ error: Error, request: URLRequest, handler: ErrorInterceptorHandler) async -> ErrorInterceptorResult {
        guard let networkError = error as? AppNetworkError,
              case .httpError(statusCode: .unauthorized, _) = networkError else {
            return handler.next(error)
        }
        tokenProvider?.clear()
        tokenExpiredSubject.send()
        return handler.next(error)
    }
}
