//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public class ApiClient {
    private let session: URLSession
    private let environment: Environment
    
    public init(configuration: URLSessionConfiguration = .default, environment: Environment) {
        self.session = URLSession(configuration: configuration)
        self.environment = environment
    }
    
    public func sendRequest(_ request: any Request) async throws -> Response {
        let builder = RequestBuilder(request: request)
        let request = builder.build(environment)
        let responseData = try await session.data(for: request)
        if let response = responseData.1 as? HTTPURLResponse {
            let statusCode = response.statusCode
            return Response(statusCode: statusCode, data: responseData.0)
        } else {
            return Response(statusCode: 200, data: responseData.0)
        }
    }
}
