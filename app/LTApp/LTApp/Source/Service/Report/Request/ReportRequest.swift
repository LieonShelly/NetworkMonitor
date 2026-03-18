//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation
import LTNetwork

enum ReportRequest: Request, @unchecked Sendable {
    case weeklyReport(week: String?)
    case weeklyReportCurrentIcons
    
    var endPoint: any EndPoint {
        var path: String = "/api"
        switch self {
        case .weeklyReport:
            path += "/weekly-report"
        case .weeklyReportCurrentIcons:
            path += "/weekly-report/current"
        }
        return DefaultEndPoint.baseURL(path: path)
    }
    
    var method: HttpMethod {
        switch self {
        case .weeklyReport, .weeklyReportCurrentIcons:
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
        }
    }
}
