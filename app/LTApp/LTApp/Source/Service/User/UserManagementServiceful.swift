//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation
import Combine

public protocol UserManagementServiceful {
    var isLogin: AnyPublisher<Bool?, Never> { get }
    var accessToken: AnyPublisher<String?, Never> { get }
}
