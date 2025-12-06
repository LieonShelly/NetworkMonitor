//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public protocol KeyValueStorageType {
    func save(value: String, key: String) throws
    
    func read(_ key: String) -> String?
    
    func delete(_ key: String)
}

public protocol KeyDataStorageType {
    func save(value: Data, key: String) throws
    
    func read(_ key: String) -> Data?
    
    func delete(_ key: String)
}

public class KeyChainStorage: KeyValueStorageType {
    
    public init() {}
    
    public func save(value: String, key: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw NSError(domain: "Data convert failed", code: -1)
        }
        let query: [String: Any] = [
            kSecClass as String : kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    public func read(_ key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String : kSecClassGenericPassword,
            kSecAttrAccount as String : key,
            kSecReturnData as String : true,
            kSecMatchLimit as String : kSecMatchLimitOne
        ]
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        
        if let data = result as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    public func delete(_ key: String) {
        let query: [String: Any] = [
            kSecClass as String : kSecClassGenericPassword,
            kSecAttrAccount as String : key,
            ]
        SecItemDelete(query as CFDictionary)
    }
}


public class UserDefaultStorage: KeyDataStorageType {
    private let userDefault: UserDefaults = .standard
    
    public init() {}
    
    public func save(value: Data, key: String) throws {
        userDefault.set(value, forKey: key)
        userDefault.synchronize()
    }
    
    public func read(_ key: String) -> Data? {
        userDefault.value(forKey: key) as? Data
    }
    
    public func delete(_ key: String) {
        userDefault.removeObject(forKey: key)
    }
}
