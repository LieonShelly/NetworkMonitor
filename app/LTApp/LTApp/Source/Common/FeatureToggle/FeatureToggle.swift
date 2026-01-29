//
//  FeatureToggle.swift
//  LTApp
//
//  Created by Renjun Li on 2026/1/29.
//

import Foundation

class FeatureToggle: FeatureToggling {
    private let appVariant: AppVariantType
    
    init(appVariant: AppVariantType) {
        self.appVariant = appVariant
    }
    
    func isEnabled(for rolloutStage: FeatureRolloutStage) -> Bool {
        rolloutStage >= appVariant.currentStage
    }
    
    func isEnabled(for featutre: FeatureConfig) -> Bool {
        isEnabled(for: featutre.stage)
    }
}
