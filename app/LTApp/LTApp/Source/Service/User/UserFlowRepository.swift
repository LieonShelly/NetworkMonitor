//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation
import LTNetwork

public protocol UserFlowRepositoryType {
    func fetchUserInfo() async throws -> User
    func updateNickname(_ nickname: String?) async throws -> UpdateNicknameResult
    func fetchQodStrategyOptions() async throws -> [QuestionOfTodaySettingItem]
    func updateQodStrategy(_ strategy: String) async throws
    func saveTimezone(_ timestamp: String) async throws -> SaveTimezoneResult
    func fetchReminder() async throws -> ReminderResult
    func updateReminder(_ slot: String?) async throws -> ReminderResult
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
    
    public func updateNickname(_ nickname: String?) async throws -> UpdateNicknameResult {
        let request = UserFlowRequest.updateNickname(nickname)
        let response = try await apiClient.sendRequest(request)
        let dto: UniversalResponse<UpdateNicknameDTO> = try response.parseJson()
        return dto.data.toDomain()
    }
    
    public func updateQodStrategy(_ strategy: String) async throws {
        let request = UserFlowRequest.updateQodStrategy(strategy)
        let _ = try await apiClient.sendRequest(request)
    }
    
    public func fetchQodStrategyOptions() async throws -> [QuestionOfTodaySettingItem] {
        let request = UserFlowRequest.qodStrategyOptions
        let response = try await apiClient.sendRequest(request)
        let dto: UniversalResponse<[QodStrategyOptions]> = try response.parseJson()
        return dto.data.map { $0.toDomain() }
    }
    
    public func saveTimezone(_ timestamp: String) async throws -> SaveTimezoneResult {
        let request = UserFlowRequest.saveTimezone(timestamp)
        let response = try await apiClient.sendRequest(request)
        let dto: UniversalResponse<SaveTimezoneDTO> = try response.parseJson()
        return dto.data.toDomain()
    }
    
    public func fetchReminder() async throws -> ReminderResult {
        let request = UserFlowRequest.fetchReminder
        let response = try await apiClient.sendRequest(request)
        let dto: UniversalResponse<ReminderDTO> = try response.parseJson()
        return dto.data.toDomain()
    }
    
    public func updateReminder(_ slot: String?) async throws -> ReminderResult {
        let request = UserFlowRequest.updateReminder(slot)
        let response = try await apiClient.sendRequest(request)
        let dto: UniversalResponse<ReminderDTO> = try response.parseJson()
        return dto.data.toDomain()
    }
}
