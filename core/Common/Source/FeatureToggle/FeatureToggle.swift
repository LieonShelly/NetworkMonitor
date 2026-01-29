//
//  FeatureToggle.swift
//  LTApp
//
//  Created by Renjun Li on 2026/1/29.
//

import Foundation

public class FeatureToggle: FeatureToggling {
    private let appVariant: AppVariantType
    
    public init(appVariant: AppVariantType) {
        self.appVariant = appVariant
    }
    
    public func isEnabled(for rolloutStage: FeatureRolloutStage) -> Bool {
        rolloutStage >= appVariant.currentStage
    }
    
    public func isEnabled(for featutre: FeatureConfig) -> Bool {
        isEnabled(for: featutre.stage)
    }
}
