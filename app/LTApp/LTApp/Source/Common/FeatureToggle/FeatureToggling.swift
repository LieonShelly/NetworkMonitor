//
//  FeatureToggling.swift
//  LTApp
//
//  Created by Renjun Li on 2026/1/29.
//


import Foundation

protocol FeatureToggling {
    
    func isEnabled(for rolloutStage: FeatureRolloutStage) -> Bool
    
    func isEnabled(for featutre: FeatureConfig) -> Bool
}

