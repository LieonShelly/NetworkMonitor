//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation

@propertyWrapper
public struct Injected<T> {
    private let keyPath: WritableKeyPath<InjectionValues, T>?
    
    public init(_ keyPath: WritableKeyPath<InjectionValues, T>) {
        self.keyPath = keyPath
    }
    
    public init() {
        self.keyPath = nil
    }
    
    public var wrappedValue: T {
        if let keyPath {
            return InjectionValues[keyPath]
        } else {
            return InjectionValues.resolve()
        }
    }
}
