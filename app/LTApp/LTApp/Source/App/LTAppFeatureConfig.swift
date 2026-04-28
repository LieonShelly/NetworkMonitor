//
//  LTAppFeatureConfig.swift
//  LTApp
//
//  Created by Renjun Li on 2026/1/29.
//

import Common

enum LTAppFeatureConfig: FeatureConfig {
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
            return .underDevelopment
        case .thread:
            return .release
        }
    }
}

struct FeatureToggleKey: InjectionKey {
    nonisolated(unsafe)
    static var currentValue: FeatureToggling = FeatureToggle(appVariant: AppVariant(currentStage: .underDevelopment))
}

extension InjectionValues {
    var featureToggle: FeatureToggling {
        get { Self[FeatureToggleKey.self]}
        set { Self[FeatureToggleKey.self] = newValue }
    }
}
