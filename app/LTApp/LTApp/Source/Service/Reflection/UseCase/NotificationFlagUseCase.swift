//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation
import Persistence

public protocol NotificationFlagUseCaseType: Sendable {
    func save() async
    
    func fetch() async -> Bool
}

public class NotificationFlagUseCase: NotificationFlagUseCaseType, @unchecked Sendable {
    private let storage: any KeyDataStorageType
    enum Constants {
        static let key = "NotificationFlagUseCase.key"
    }
    
    public init(storage: any KeyDataStorageType) {
        self.storage = storage
    }
    
    public func save() async {
        try? storage.save(value: "\(true)".data(using: .utf8)!, key: Constants.key)
    }
    
    public func fetch() async -> Bool {
        let result = storage.read(Constants.key)
        return result != nil
    }
}
