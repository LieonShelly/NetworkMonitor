//
//  FetureConfig.swift
//  LTApp
//
//  Created by Renjun Li on 2026/1/29.
//

import Foundation

public protocol FeatureConfig {
    var stage: FeatureRolloutStage { get }
}
