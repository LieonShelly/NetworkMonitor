//
//  FeatureToggle.swift
//  LTApp
//
//  Created by Renjun Li on 2026/1/29.
//

import Foundation

class FeatureToggle: FeatureToggling {
    private let appVariant: AppVariant
    
    init(appVariant: AppVariant) {
        self.appVariant = appVariant
    }
    
    func isEnabled(for rolloutStage: FeatureRolloutStage) -> Bool {
        rolloutStage >= appVariant.currentStage
    }
}
