//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation
import Combine

class SessionService: ObservableObject, TokenProvider, @unchecked Sendable {
    @Published private(set) var accessToken: String? = nil
    var refreshToken: String? {
        storage.read(StorageKey.refreshToken)
    }
    private let storage: any KeyValueStorageType
    enum StorageKey {
        static let refreshToken = "refreshToken"
    }
    
    init(storage: any KeyValueStorageType) {
        self.storage = storage
    }
    
    func updateTokens(accessToken: String, refreshToken: String) throws {
        self.accessToken = accessToken
        try storage.save(value: refreshToken, key: StorageKey.refreshToken)
    }
    
    func clear() {
        accessToken = nil
        storage.delete(StorageKey.refreshToken)
    }
}
