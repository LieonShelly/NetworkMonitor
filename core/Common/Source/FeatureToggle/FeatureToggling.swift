//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation

public protocol FeatureToggling {
    
    func isEnabled(for rolloutStage: FeatureRolloutStage) -> Bool
    
    func isEnabled(for featutre: FeatureConfig) -> Bool
}
