//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public protocol AuthRepositoryType {
    func login(appleId: String, authToken: String) async throws -> User
}


public final class AuthRepository: AuthRepositoryType {
    private let apiClient: ApiClient
    
    public  init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    public func login(appleId: String, authToken: String) async throws -> User {
        let request = AuthRequest.login(appleId: appleId, authToken: authToken)
        let response = try await apiClient.sendRequest(request)
        let userDto: UniversalResponse<UserDTO> = try response.parseJson()
        return userDto.data.toDomain()
    }
}
