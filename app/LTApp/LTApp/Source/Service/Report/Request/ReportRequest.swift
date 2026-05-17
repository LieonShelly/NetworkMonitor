//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation
import LTNetwork

enum ReportRequest: Request, @unchecked Sendable {
    case weeklyReport(week: String?)
    case weeklyReportCurrentIcons
    case weeklyReportPrevIcons
    case weeklyReportsList(limit: Int?, cursor: String?, isRead: Bool?)
    case markWeeklyReportRead(week: String)
    
    var endPoint: any EndPoint {
        var path: String = "/api"
        switch self {
        case .weeklyReport:
            path += "/weekly-report"
        case .weeklyReportCurrentIcons:
            path += "/weekly-report/current"
        case .weeklyReportPrevIcons:
            path += "/weekly-report/prev"
        case .weeklyReportsList:
            path += "/weekly-reports"
        case .markWeeklyReportRead:
            path += "/weekly-report/read"
        }
        return DefaultEndPoint.baseURL(path: path)
    }
    
    var method: HttpMethod {
        switch self {
        case .weeklyReport, .weeklyReportCurrentIcons, .weeklyReportPrevIcons, .weeklyReportsList:
            return .get
        case .markWeeklyReportRead:
            return .post
        }
    }
    
    var payload: HttpPayload {
        switch self {
        case let .weeklyReport(week):
            if let week {
                return .urlEncoding([("week", week)])
            }
            return .empty
        case .weeklyReportCurrentIcons, .weeklyReportPrevIcons:
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
        case let .markWeeklyReportRead(week):
            return .json(body: ["week": week], urlParameter: nil)
        }
    }
}
