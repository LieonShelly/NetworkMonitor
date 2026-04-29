//
//  LTLogSink.swift
//  LTCommon
//
//  Created by Renjun Li on 2026/4/29.
//

public protocol LTLogSink: Sendable {
    func log(_ event: LTLogEvent)
}
