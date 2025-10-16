//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

enum DefaultEndPoint: EndPoint {
    case baseURL(path: String)
    
    func absoluteUrl(_ environment: AppEnvironment) -> URL {
        switch self {
        case .baseURL(let path):
            var components = URLComponents(string: path)
            components?.scheme = "https"
            components?.host = "things.dvacode.tech"
            return components!.url!
        }
    }
}
