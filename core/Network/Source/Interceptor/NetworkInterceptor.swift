//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public protocol NetworkInterceptor: Sendable {
    func adapt(_ request: URLRequest) async throws -> URLRequest
    
    func shouldRetry(_ request: URLRequest, response: URLResponse?) async throws -> Bool
    
    func abort(_ request: URLRequest, response: URLResponse?) async throws -> Bool
}

extension NetworkInterceptor {
    public func abort(_ request: URLRequest, response: URLResponse?) async throws -> Bool {
        return false
    }
}
