//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public protocol ApiClientType {
    func sendRequest(_ request: any Request) async throws -> Response
}

public class ApiClient: ApiClientType, @unchecked Sendable {
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
    
    public func sendSSERequest<T: Codable>(_ request: any Request) -> AsyncThrowingStream<T, any Error> where T: Sendable {
       return AsyncThrowingStream { continuation in
            let task = Task.detached {
                let builder = RequestBuilder(request: request)
                var urlRequest = builder.build(self.environment)
                let interceptors = self.interceptors
                urlRequest.timeoutInterval = .infinity
                urlRequest.setValue("text/event-stream", forHTTPHeaderField: "Accept")
                for interceptor in interceptors {
                    urlRequest = try await interceptor.adapt(urlRequest)
                }
                do {
                    let bytes = try await self.session.bytes(for: urlRequest)
                    guard let httpResonse = bytes.1 as? HTTPURLResponse, httpResonse.statusCode == 200 else {
                        continuation.finish(throwing: URLError(.badServerResponse))
                        return
                    }
                    for try await line in bytes.0.lines {
                        if line.hasPrefix("data:") {
                            let jsonString = line.dropFirst(5).trimmingCharacters(in: .whitespaces)
                            print("SSE:\(jsonString)")
                       
                            if let data = jsonString.data(using: .utf8) {
                                if let jsonData = try JSONSerialization.jsonObject(with: data) as? [String: Any], let dataStr = jsonData["data"] as? [String: Any] {
                                    let data = try JSONSerialization.data(withJSONObject: dataStr)
                                    let reponse = try JSONDecoder().decode(T.self, from: data)
                                    continuation.yield(reponse)
                                }
                            }
                        }
                    }
                    print("SSE: finish")
                    continuation.finish()
                } catch {
                    print("SSE ERROR: \(error)")
                    continuation.finish(throwing: error)
                }
            }
            
            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }
}
