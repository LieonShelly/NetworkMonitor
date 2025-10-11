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

