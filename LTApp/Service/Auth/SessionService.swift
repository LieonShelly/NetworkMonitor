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
        accessToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJjbWdhbXh4M3EwMDAwcHA3M2tvbWs1ZGFvIiwiYXBwbGVJZCI6IjAwMTc3NC5mYjZiNjFiMjk5MmU0NjgzOGJlZTM0ZTc4MWE2YTExNC4xMDIxIiwidHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NTk0ODM5NTQsImV4cCI6MTc2MDc3OTk1NH0.XO3_bpWSGIT49mYPhQ582OR5sHQB8GdpG9b18QyyFrI"
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
