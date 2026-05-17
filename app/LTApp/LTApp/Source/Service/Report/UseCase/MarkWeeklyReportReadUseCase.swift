//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation

public protocol MarkWeeklyReportReadUseCaseType: Sendable {
    func execute(week: String) async throws -> WeeklyReportReadResult
}

public class MarkWeeklyReportReadUseCase: MarkWeeklyReportReadUseCaseType, @unchecked Sendable {
    private let repository: any ReportRepositoryType
    
    public init(repository: any ReportRepositoryType) {
        self.repository = repository
    }
    
    public func execute(week: String) async throws -> WeeklyReportReadResult {
        try await repository.markWeeklyReportRead(week: week)
    }
}
