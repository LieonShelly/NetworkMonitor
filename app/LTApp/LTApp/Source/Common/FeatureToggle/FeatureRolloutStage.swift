//
//  FeatureRolloutStage.swift
//  LTApp
//
//  Created by Renjun Li on 2026/1/29.
//

import Foundation

enum FeatureRolloutStage: Int, Comparable {
    case underDevelopment = 0
    case `internal` = 1
    case release = 2
    
    static func < (lhs: FeatureRolloutStage, rhs: FeatureRolloutStage) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
