//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation
import LTNetwork

public protocol ReportRepositoryType {
    func fetchWeeklyReport(week: String?) async throws -> WeeklyReport
    func fetchWeeklyReportCurrentIcons() async throws -> WeeklyReportCurrentIcons
    func fetchWeeklyReportsList(limit: Int?, cursor: String?, isRead: Bool?) async throws -> WeeklyReportsList
    func markWeeklyReportRead(week: String) async throws -> WeeklyReportReadResult
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
    
    public func fetchWeeklyReportCurrentIcons() async throws -> WeeklyReportCurrentIcons {
        let request = ReportRequest.weeklyReportCurrentIcons
        let response = try await apiClient.sendRequest(request)
        let dto: UniversalResponse<WeeklyReportCurrentIconsDTO> = try response.parseJson()
        return dto.data.toDomain()
    }
    
    public func fetchWeeklyReportsList(limit: Int?, cursor: String?, isRead: Bool?) async throws -> WeeklyReportsList {
        let request = ReportRequest.weeklyReportsList(limit: limit, cursor: cursor, isRead: isRead)
        let response = try await apiClient.sendRequest(request)
        let dto: UniversalResponse<WeeklyReportsListDTO> = try response.parseJson()
        return dto.data.toDomain()
    }
    
    public func markWeeklyReportRead(week: String) async throws -> WeeklyReportReadResult {
        let request = ReportRequest.markWeeklyReportRead(week: week)
        let response = try await apiClient.sendRequest(request)
        let dto: UniversalResponse<WeeklyReportReadResultDTO> = try response.parseJson()
        return dto.data.toDomain()
    }
}
