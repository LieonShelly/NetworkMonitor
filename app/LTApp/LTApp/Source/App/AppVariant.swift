//
//  AppVariant.swift
//  LTApp
//
//  Created by Renjun Li on 2026/1/29.
//

import Foundation
import Common

public struct AppVariant: AppVariantType {
    
   public let currentStage: FeatureRolloutStage
    
   public init(currentStage: FeatureRolloutStage) {
        self.currentStage = currentStage
    }
}
