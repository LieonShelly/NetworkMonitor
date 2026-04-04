//
//  HandDrawnCapsule.swift
//  UIComponent
//
//  Created by Renjun Li on 2026/4/4.
//

import SwiftUI

public struct HandDrawnCapsule: Shape {
    var amplitude: CGFloat = 1
    var frequency: CGFloat = 1
    
    public init(amplitude: CGFloat = 1, frequency: CGFloat = 1) {
        self.amplitude = amplitude
        self.frequency = frequency
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let radius = height / 2.0
        
        let startX = radius
        let endX = max(radius, width - radius)
        
        path.move(to: CGPoint(x: startX, y: sin(startX * frequency) * amplitude))
        for x in stride(from: startX, through: endX, by: 3) {
            let y = sin(x * frequency) * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        for angle in stride(from: -90.0, through: 90.0, by: 4.0) {
            let rad = angle * .pi / 180
            let waveRadius = radius + sin(angle * frequency) * amplitude
            let cx = endX
            let cy = radius
            path.addLine(to: CGPoint(x: cx + cos(rad) * waveRadius, y: cy + sin(rad) * waveRadius))
        }
        
        for x in stride(from: endX, through: startX, by: -3) {
            let y = height + sin(x * frequency) * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        for angle in stride(from: 90.0, through: 270.0, by: 4.0) {
            let rad = angle * .pi / 180
            let waveRadius = radius + sin(angle * frequency) * amplitude
            let cx = radius
            let cy = radius
            path.addLine(to: CGPoint(x: cx + cos(rad) * waveRadius, y: cy + sin(rad) * waveRadius))
        }
        
        path.closeSubpath()
        return path
    }
}
