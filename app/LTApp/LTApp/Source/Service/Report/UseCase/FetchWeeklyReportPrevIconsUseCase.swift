//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation

public protocol FetchWeeklyReportPrevIconsUseCaseType: Sendable {
    func execute() async throws -> WeeklyReportCurrentIcons
}

public class FetchWeeklyReportPrevIconsUseCase: FetchWeeklyReportPrevIconsUseCaseType, @unchecked Sendable {
    private let repository: any ReportRepositoryType
    
    public init(repository: any ReportRepositoryType) {
        self.repository = repository
    }
    
    public func execute() async throws -> WeeklyReportCurrentIcons {
        try await repository.fetchWeeklyReportPrevIcons()
    }
}
