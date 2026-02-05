//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation
import Combine
import Persistence

public protocol UserManagementServiceful {
    var isLogin: AnyPublisher<Bool?, Never> { get }
    var user: AnyPublisher<User?, Never> { get }
    
    func updateUser(_ user: User) throws
    
    func clear() throws
}

public final class UserManagementService: UserManagementServiceful {
    public var isLogin: AnyPublisher<Bool?, Never> {
        return user.map { $0 != nil }.eraseToAnyPublisher()
    }
    public var user: AnyPublisher<User?, Never> {
        userSubject.eraseToAnyPublisher()
    }
    private var userKey = "user.little.thing"
    private let userSubject: CurrentValueSubject<User?, Never> = .init(nil)
    let storage: UserDefaultStorage = .init()
    
    public func updateUser(_ user: User) throws {
        userSubject.value = user
        // TODO
    }
    
    public func clear() throws {
        storage.delete(userKey)
        userSubject.value = nil
    }
}
