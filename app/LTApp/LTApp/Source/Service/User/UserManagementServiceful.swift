//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation
import Combine
import Persistence
import GoogleSignIn

public protocol UserManagementServiceful: Sendable {
    var user: AnyPublisher<User?, Never> { get }
    
    func fetchUserInfo() async throws
    
    func updateUser(_ user: User) throws
    
    func clear() throws
}

public final class UserManagementService: @unchecked Sendable, UserManagementServiceful {

    public var user: AnyPublisher<User?, Never> {
        userSubject.eraseToAnyPublisher()
    }
    private let userKey = "user.little.thing"
    private let userSubject: CurrentValueSubject<User?, Never> = .init(nil)
    let storage: UserDefaultStorage = .init()
    let repository: any UserFlowRepositoryType
    
    public init(repository: any UserFlowRepositoryType) {
        
        self.repository = repository
    }
    
    public func updateUser(_ user: User) throws {
        userSubject.value = user
        // TODO: To cache User info into local database
    }
    
    public func clear() throws {
        userSubject.value = nil
        let userKey = self.userKey
        Task.detached {
            self.storage.delete(userKey)
            GIDSignIn.sharedInstance.signOut()
        }
    }
    
    public func fetchUserInfo() async throws {
       let userInfo = try await repository.fetchUserInfo()
       try updateUser(userInfo)
    }
}
