//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation

public enum FeatureRolloutStage: Int, Comparable {
    case underDevelopment = 0
    case `internal` = 1
    case release = 2
    
    public static func < (lhs: FeatureRolloutStage, rhs: FeatureRolloutStage) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
