//
//  InjectionKey.swift
//  LTApp
//
//  Created by Renjun Li on 2026/1/29.
//

import Foundation

public protocol InjectionKey {
    associatedtype Value
    static var currentValue: Value { get set }
}
