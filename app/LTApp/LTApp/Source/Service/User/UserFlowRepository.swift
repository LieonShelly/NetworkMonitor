//
//  UserRepositoryType.swift
//  LTApp
//
//  Created by Renjun Li on 2026/2/5.
//

import Foundation
import LTNetwork

public protocol UserFlowRepositoryType {
    func fetchUserInfo() async throws -> User
    
    func updateQodStrategy(_ strategy: String) async throws
    
}

public final class UserFlowRepository: UserFlowRepositoryType, @unchecked Sendable {
    private let apiClient: ApiClient
    
    public init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    
    public func fetchUserInfo() async throws -> User {
        let request = UserFlowRequest.userInfo
        let response = try await apiClient.sendRequest(request)
        let dto: UniversalResponse<UserInfoDTO> = try response.parseJson()
        return dto.data.toDomain()
    }
    
    public func updateQodStrategy(_ strategy: String) async throws {
        let request = UserFlowRequest.updateQodStrategy(strategy)
        let _ = try await apiClient.sendRequest(request)
    }
}
