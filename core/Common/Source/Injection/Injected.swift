//
//  Injected.swift
//  LTApp
//
//  Created by Renjun Li on 2026/1/29.
//

import Foundation

@propertyWrapper
public struct Injected<T> {
    private let keyPath: WritableKeyPath<InjectionValues, T>?
    
    public init(_ keyPath: WritableKeyPath<InjectionValues, T>) {
        self.keyPath = keyPath
    }
    
    public  init() {
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

