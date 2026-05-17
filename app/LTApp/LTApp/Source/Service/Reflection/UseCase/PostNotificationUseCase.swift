//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
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
