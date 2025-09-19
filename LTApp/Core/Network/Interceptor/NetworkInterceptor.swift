//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public protocol NetworkInterceptor {
    func adapt(_ request: URLRequest) async throws -> URLRequest
    
    func shouldRetry(_ request: URLRequest, response: URLResponse?) async throws -> Bool
}
