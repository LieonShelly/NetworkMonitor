//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
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
