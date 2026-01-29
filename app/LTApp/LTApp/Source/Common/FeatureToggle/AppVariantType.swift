//
//  AppVariant.swift
//  LTApp
//
//  Created by Renjun Li on 2026/1/29.
//

import Foundation

protocol AppVariantType {
    var currentStage: FeatureRolloutStage { get }
}
