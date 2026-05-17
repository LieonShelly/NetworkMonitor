//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation

public protocol FetchWeeklyReportCurrentIconsUseCaseType: Sendable {
    func execute() async throws -> WeeklyReportCurrentIcons
}

public class FetchWeeklyReportCurrentIconsUseCase: FetchWeeklyReportCurrentIconsUseCaseType, @unchecked Sendable {
    private let repository: any ReportRepositoryType
    
    public init(repository: any ReportRepositoryType) {
        self.repository = repository
    }
    
    public func execute() async throws -> WeeklyReportCurrentIcons {
        try await repository.fetchWeeklyReportCurrentIcons()
    }
}
