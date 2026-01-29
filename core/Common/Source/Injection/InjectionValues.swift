//
//  InjectionValues.swift
//  LTApp
//
//  Created by Renjun Li on 2026/1/29.
//

import Foundation

public struct InjectionValues {
    public init() { }
    
    public static subscript<K>(key: K.Type) -> K.Value where K: InjectionKey {
        get { key.currentValue }
        set { key.currentValue = newValue }
    }
    
    public static subscript<T>(_ keyPath: WritableKeyPath<InjectionValues, T>) -> T {
        get {
            let proxy = InjectionValues()
            return proxy[keyPath: keyPath]
        }
        set {
            var proxy = InjectionValues()
             proxy[keyPath: keyPath] = newValue
        }
    }
    
    public static func register<T>(_ type: T.Type, component: T) {
        Storage.shared.register(type, component: component)
    }
    
    public static func resolve<T>() -> T {
        guard let component: T = Storage.shared.resolve() else {
            fatalError()
        }
        return component
    }
}

private final class Storage: @unchecked Sendable {
    private let lock = NSRecursiveLock()
    private var typeProviders: [ObjectIdentifier: Any] = [:]
    static let shared = Storage()
    
    func register<T>(_ type: T.Type, component: T) {
        lock.withLock {
            let key = ObjectIdentifier(type)
            typeProviders[key] = component
        }
    }
    
    func resolve<T>() -> T? {
        lock.withLock {
            let key = ObjectIdentifier(T.self)
            return typeProviders[key] as? T
        }
    }
}

extension NSLocking {
    func withLock<T> (_ body: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try body()
    }
}
