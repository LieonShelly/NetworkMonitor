//
//  InjectionValues.swift
//  LTApp
//
//  Created by Renjun Li on 2026/1/29.
//

import Foundation

struct InjectionValues {
    nonisolated(unsafe)
    private static var current = InjectionValues()
    
    static subscript<K>(key: K.Type) -> K.Value where K: InjectionKey {
        get { key.currentValue }
        set { key.currentValue = newValue }
    }
    
    static subscript<T>(_ keyPath: WritableKeyPath<InjectionValues, T>) -> T {
        get { current[keyPath: keyPath] }
        set { current[keyPath: keyPath] = newValue }
    }
    
    nonisolated(unsafe)
    private static var typeProviders: [ObjectIdentifier: Any] = [:]
    
    static func register<T>(_ type: T.Type, component: T) {
        let key = ObjectIdentifier(type)
        typeProviders[key] = component
    }
    
    static func resolve<T>() -> T {
        let key = ObjectIdentifier(T.self)
        guard let component = typeProviders[key] as? T else {
            fatalError()
        }
        return component
    }
}
