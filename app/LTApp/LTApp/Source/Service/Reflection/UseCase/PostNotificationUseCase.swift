//
//  PostNotificationUseCaseType.swift
//  LTApp
//
//  Created by Renjun Li on 2025/12/18.
//

import Foundation

public protocol PostNotificationDeviceTokenUseCaseType: Sendable {
    func execute(deviceToken: String) async throws
}

public class PostNotificationDeviceTokenUseCase: PostNotificationDeviceTokenUseCaseType, @unchecked Sendable {
    private let repository: any NotificationRepositoryType
    
    public init(repository: any NotificationRepositoryType) {
        self.repository = repository
    }
    
    public func execute(deviceToken: String) async throws {
       try await repository.postDeviceToken(deviceToken)
    }
}
