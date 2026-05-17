//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation

public protocol FetchWeeklyReportUseCaseType: Sendable {
    func execute(week: String?) async throws -> WeeklyReport
}

public class FetchWeeklyReportUseCase: FetchWeeklyReportUseCaseType, @unchecked Sendable {
    private let repository: any ReportRepositoryType
    
    public init(repository: any ReportRepositoryType) {
        self.repository = repository
    }
    
    public func execute(week: String?) async throws -> WeeklyReport {
        try await repository.fetchWeeklyReport(week: week)
    }
}
