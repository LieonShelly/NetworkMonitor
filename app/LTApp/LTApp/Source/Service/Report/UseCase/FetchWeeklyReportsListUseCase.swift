//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public protocol FetchWeeklyReportsListUseCaseType: Sendable {
    func execute(limit: Int?, cursor: String?, isRead: Bool?) async throws -> WeeklyReportsList
}

public class FetchWeeklyReportsListUseCase: FetchWeeklyReportsListUseCaseType, @unchecked Sendable {
    private let repository: any ReportRepositoryType
    
    public init(repository: any ReportRepositoryType) {
        self.repository = repository
    }
    
    public func execute(limit: Int?, cursor: String?, isRead: Bool?) async throws -> WeeklyReportsList {
        try await repository.fetchWeeklyReportsList(limit: limit, cursor: cursor, isRead: isRead)
    }
}
