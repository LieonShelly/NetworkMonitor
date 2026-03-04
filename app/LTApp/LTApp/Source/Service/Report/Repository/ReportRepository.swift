//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation
import LTNetwork

public protocol ReportRepositoryType {
    func fetchWeeklyReport(week: String?) async throws -> WeeklyReport
}

public final class ReportRepository: ReportRepositoryType {
    private let apiClient: ApiClient
    
    public init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    public func fetchWeeklyReport(week: String?) async throws -> WeeklyReport {
        let request = ReportRequest.weeklyReport(week: week)
        let response = try await apiClient.sendRequest(request)
        let dto: UniversalResponse<WeeklyReportDTO> = try response.parseJson()
        return dto.data.toDomain()
    }
}
