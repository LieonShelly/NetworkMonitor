//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation
import LTNetwork

enum DefaultEndPoint: EndPoint {
    case baseURL(path: String)
    
    func absoluteUrl(_ environment: AppEnvironment) -> URL {
        switch environment {
        case .dev:
            switch self {
            case .baseURL(let path):
                var components = URLComponents(string: path)
                components?.scheme = "https"
                components?.host = "things.dvacode.tech"
                return components!.url!
            }
        case .stagging:
            switch self {
            case .baseURL(let path):
                var components = URLComponents(string: path)
                components?.scheme = "https"
                components?.host = "things.dvacode.tech"
                return components!.url!
            }
        case .release:
            switch self {
            case .baseURL(let path):
                var components = URLComponents(string: path)
                components?.scheme = "https"
                components?.host = "things.vsvx-infotech.com"
                return components!.url!
            }
        }
    }
}
