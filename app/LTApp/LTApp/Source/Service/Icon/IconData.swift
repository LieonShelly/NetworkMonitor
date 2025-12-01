//
//  IconStatus.swift
//  LTApp
//
//  Created by Renjun Li on 2025/12/1.
//

import Foundation

public enum IconStatus: String, Sendable {
    case pending = "PENDING"
    case generated = "GENERATED"
    case failed = "FAILED"
}

public struct IconData: Sendable {
    let status: IconStatus
    let url: String
    let iconId: String?
}

extension IconGeneratingStatus {
    func toDomain() -> IconStatus {
        return .init(rawValue: rawValue) ?? .failed
    }
}

extension IconDto {
    func toDomain() -> IconData {
        return  .init(
            status: .init(rawValue: status?.rawValue ?? "") ?? .failed,
            url: url ?? "",
            iconId: iconId
        )
    }
}
