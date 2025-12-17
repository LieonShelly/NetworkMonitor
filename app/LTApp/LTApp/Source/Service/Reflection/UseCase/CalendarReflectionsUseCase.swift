//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public protocol CalendarReflectionsUseCaseType: Sendable {
    func execute(startMonth: Date, endMonth: Date) async throws -> [DayReflections]
}

public class CalendarReflectionsUseCase: CalendarReflectionsUseCaseType, @unchecked Sendable {
    private let repository: any ReflectionRepositoryType
    
    public init(repository: any ReflectionRepositoryType) {
        self.repository = repository
    }
    
    public func execute(startMonth: Date, endMonth: Date) async throws -> [DayReflections] {
        try await repository.fetchCalendarReflections(startMonth: startMonth, endMonth: endMonth)
    }
}

import Foundation

public protocol PostNotificationUseCaseType: Sendable {
    func execute(deviceToken: String) async throws
}

public class PostNotificationUseCase: PostNotificationUseCaseType, @unchecked Sendable {
    private let repository: any NotificationRepositoryType
    
    public init(repository: any NotificationRepositoryType) {
        self.repository = repository
    }
    
    public func execute(deviceToken: String) async throws {
       try await repository.postDeviceToken(deviceToken)
    }
}
