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
    var status: IconStatus
    var url: String?
    let iconId: String?
    let readAt: Date?
}

extension IconGeneratingStatus {
    func toDomain() -> IconStatus {
        return .init(rawValue: rawValue) ?? .failed
    }
}

extension IconDto {
    func toDomain(_ outstatus: IconStatus = .failed) -> IconData {
        let readAtDate: Date? = {
            guard let readAt else { return nil }
            return AppDateFormatter.iso8601.date(from: readAt)
        }()
        return  .init(
            status: .init(rawValue: status?.rawValue ?? "") ?? outstatus,
            url: url ?? "",
            iconId: id,
            readAt: readAtDate
        )
    }
}
