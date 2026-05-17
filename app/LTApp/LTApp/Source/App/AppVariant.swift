//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation
import Common

public struct AppVariant: AppVariantType {
    
   public let currentStage: FeatureRolloutStage
    
   public init(currentStage: FeatureRolloutStage) {
        self.currentStage = currentStage
    }
}
