//
//  CancellableBox.swift
//  LTApp
//
//  Created by Renjun Li on 2026/1/19.
//

import Combine

public final class CancellableBox: @unchecked Sendable {
    public var value: AnyCancellable?
    
    public init(value: AnyCancellable? = nil) {
        self.value = value
    }
    
    public func cancel() {
        value?.cancel()
    }
}

enum LTAppFeatureConfig: FetureConfig {
    case logout
    case insights
    case calendarView
    case thread
    
    var stage: FeatureRolloutStage {
        switch self {
        case .logout:
            return .underDevelopment
        case .insights:
            return .internal
        case .calendarView:
            return .release
        case .thread:
            return .release
        }
    }
}
