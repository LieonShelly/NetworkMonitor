//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
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

public protocol FetchReadWeeklyReportsUseCaseType: Sendable {
    func execute(limit: Int?, cursor: String?) async throws -> WeeklyReportsList
}

public class FetchReadWeeklyReportsUseCase: FetchReadWeeklyReportsUseCaseType, @unchecked Sendable {
    private let repository: any ReportRepositoryType
    
    public init(repository: any ReportRepositoryType) {
        self.repository = repository
    }
    
    public func execute(limit: Int?, cursor: String?) async throws -> WeeklyReportsList {
        try await repository.fetchWeeklyReportsList(limit: limit, cursor: cursor, isRead: true)
    }
}

public protocol FetchUnreadWeeklyReportsUseCaseType: Sendable {
    func execute(limit: Int?, cursor: String?) async throws -> WeeklyReportsList
}

public class FetchUnreadWeeklyReportsUseCase: FetchUnreadWeeklyReportsUseCaseType, @unchecked Sendable {
    private let repository: any ReportRepositoryType
    
    public init(repository: any ReportRepositoryType) {
        self.repository = repository
    }
    
    public func execute(limit: Int?, cursor: String?) async throws -> WeeklyReportsList {
        try await repository.fetchWeeklyReportsList(limit: limit, cursor: cursor, isRead: false)
    }
}
