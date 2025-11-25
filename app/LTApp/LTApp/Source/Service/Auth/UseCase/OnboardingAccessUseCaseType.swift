//
//  LTApp, This code is protected by intellectual property rights.
//

import Persistence

public protocol OnboardingAccessUseCaseType {
    var isEnabled: Bool { get }
    
    func disabled()
    
    func reset()
}


public class OnboardingAccessUseCase: OnboardingAccessUseCaseType {
    private let storage: any KeyValueStorageType
    
    enum StorageKey {
        static let onboardingKey = "onboardingKey"
    }
    
    public init(storage: any KeyValueStorageType) {
        self.storage = storage
    }
    
    public var isEnabled: Bool {
        storage.read(StorageKey.onboardingKey) == nil
    }
    
    public func disabled() {
        try? storage.save(value: "onboarding", key: StorageKey.onboardingKey)
    }
    
    public func reset() {
        storage.delete(StorageKey.onboardingKey)
    }
    
}
