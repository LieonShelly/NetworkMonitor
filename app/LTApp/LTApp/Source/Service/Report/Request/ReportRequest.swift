//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation
import LTNetwork

enum ReportRequest: Request, @unchecked Sendable {
    case weeklyReport(week: String?)
    
    var endPoint: any EndPoint {
        var path: String = "/api"
        switch self {
        case .weeklyReport:
            path += "/weekly-report"
        }
        return DefaultEndPoint.baseURL(path: path)
    }
    
    var method: HttpMethod {
        switch self {
        case .weeklyReport:
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
        }
    }
}
