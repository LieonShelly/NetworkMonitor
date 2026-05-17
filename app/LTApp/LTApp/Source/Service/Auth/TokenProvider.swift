//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation

public protocol TokenProvider: AnyObject {
    var accessToken: String? { get }
    var refreshToken: String? { get }
    
    func updateTokens(accessToken: String, refreshToken: String) throws
    
    func clear()
}
