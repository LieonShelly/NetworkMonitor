//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import SwiftUI

public struct Trapezoid: Shape {
    public enum Direction: Sendable {
        case top
        case bottom
    }
    let padding: CGFloat
    let direction: Direction
    
    public init(padding: CGFloat, direction: Direction) {
        self.padding = padding
        self.direction = direction
    }
    
    nonisolated public func path(in rect: CGRect) -> Path {
        var path = Path()
        var topLeft: CGPoint = .zero
        var topRight: CGPoint = .zero
        var bottomLeft: CGPoint = .zero
        var bottomRight: CGPoint = .zero
        
        switch direction {
        case .top:
            topLeft = CGPoint(x: rect.minX + padding, y: rect.minY)
            topRight = CGPoint(x: rect.maxX - padding, y: rect.minY)
            bottomLeft = CGPoint(x: rect.minX , y: rect.maxY)
            bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
            
        case .bottom:
            topLeft = CGPoint(x: rect.minX, y: rect.minY)
            topRight = CGPoint(x: rect.maxX, y: rect.minY)
            bottomLeft = CGPoint(x: rect.minX + padding , y: rect.maxY)
            bottomRight = CGPoint(x: rect.maxX - padding, y: rect.maxY)
        }
       
        path.move(to: topLeft)
        path.addLine(to: topRight)
        path.addLine(to: bottomRight)
        path.addLine(to: bottomLeft)
        path.closeSubpath()
        return path
    }
}
