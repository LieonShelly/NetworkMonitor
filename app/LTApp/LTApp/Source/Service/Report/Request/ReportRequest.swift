//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation
import LTNetwork

enum ReportRequest: Request, @unchecked Sendable {
    case weeklyReport(week: String?)
    case weeklyReportCurrentIcons
    case weeklyReportsList(limit: Int?, cursor: String?, isRead: Bool?)
    
    var endPoint: any EndPoint {
        var path: String = "/api"
        switch self {
        case .weeklyReport:
            path += "/weekly-report"
        case .weeklyReportCurrentIcons:
            path += "/weekly-report/current"
        case .weeklyReportsList:
            path += "/weekly-reports"
        }
        return DefaultEndPoint.baseURL(path: path)
    }
    
    var method: HttpMethod {
        switch self {
        case .weeklyReport, .weeklyReportCurrentIcons, .weeklyReportsList:
            return .get
        }
    }
    
    var payload: HttpPayload {
        switch self {
        case let .weeklyReport(week):
            if let week {
                return .urlEncoding([("week", week)])
            }
            return .empty
        case .weeklyReportCurrentIcons:
            return .empty
        case let .weeklyReportsList(limit, cursor, isRead):
            var params: [(String, String)] = []
            if let limit {
                params.append(("limit", "\(limit)"))
            }
            if let cursor {
                params.append(("cursor", cursor))
            }
            if let isRead {
                params.append(("isRead", isRead ? "true" : "false"))
            }
            return params.isEmpty ? .empty : .urlEncoding(params)
        }
    }
}
