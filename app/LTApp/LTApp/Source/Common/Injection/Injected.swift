//
//  Injected.swift
//  LTApp
//
//  Created by Renjun Li on 2026/1/29.
//

import Foundation

@propertyWrapper
struct Injected<T> {
    private let keyPath: WritableKeyPath<InjectionValues, T>?
    
    init(_ keyPath: WritableKeyPath<InjectionValues, T>) {
        self.keyPath = keyPath
    }
    
    init() {
        self.keyPath = nil
    }
    
    var wrappedValue: T {
        if let keyPath {
            return InjectionValues[keyPath]
        } else {
            return InjectionValues.resolve()
        }
    }
}

