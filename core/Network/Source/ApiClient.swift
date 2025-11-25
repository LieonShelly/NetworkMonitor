//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public protocol ApiClientType {
    func sendRequest(_ request: any Request) async throws -> Response
}

public class ApiClient: ApiClientType {
    private let session: URLSession
    private let environment: AppEnvironment
    private let interceptors: [NetworkInterceptor]
    
    public init(
        configuration: URLSessionConfiguration = .default,
        environment: AppEnvironment,
        interceptors: [NetworkInterceptor]
    ) {
        self.session = URLSession(configuration: configuration)
        self.environment = environment
        self.interceptors = interceptors
    }
    
    public func sendRequest(_ request: any Request) async throws -> Response {
        let builder = RequestBuilder(request: request)
        var urlRequest = builder.build(environment)
        
        for interceptor in interceptors {
            urlRequest = try await interceptor.adapt(urlRequest)
        }
        
        let responseData = try await session.data(for: urlRequest)
        guard let response = responseData.1 as? HTTPURLResponse else {
            throw AppNetworkError.dataError(debugDescription: "Data error")
        }
        let statusCode = response.statusCode
        print("[ApiClient]:\(request.endPoint.absoluteUrl(.dev)) - statusCode: \(statusCode)")
        switch statusCode {
        case 200 ..< 300:
            return Response(statusCode: statusCode, data: responseData.0)
        case 401:
            for interceptor in interceptors {
                let shouldRetry = try await interceptor.shouldRetry(urlRequest, response: response)
                if shouldRetry {
                    return try await sendRequest(request)
                }
                if try await interceptor.abort(urlRequest, response: response) {
                    throw AppNetworkError.httpError(
                        statusCode: .init(rawValue: statusCode) ??  HttpErrorCode.badRequest,
                        body: responseData.0)
                }
            }
        default:
            throw AppNetworkError.httpError(
                statusCode: .init(rawValue: statusCode) ??  HttpErrorCode.badRequest,
                body: responseData.0)
        }
        throw AppNetworkError.dataError(debugDescription: "Data error")
    }
}
