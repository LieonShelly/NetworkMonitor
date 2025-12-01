//
//  IconGeneratingStatus 2.swift
//  LTApp
//
//  Created by Renjun Li on 2025/12/1.
//

import Foundation

public enum IconGeneratingStatus: String, Codable {
    case pending = "PENDING"
    case generated = "GENERATED"
    case failed = "FAILED"
}

public struct IconDto: Codable {
    let status: IconGeneratingStatus?
    let url: String?
    let id: String?
}
