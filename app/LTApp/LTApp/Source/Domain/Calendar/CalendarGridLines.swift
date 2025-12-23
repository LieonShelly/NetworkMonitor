//
//  CalendarGridLines.swift
//  LTApp
//
//  Created by Renjun Li on 2025/12/23.
//
import SwiftUI
import UIComponent

struct CalendarGridLines: View {
    let columns: Int
    let rowHeight: CGFloat
    let color: Color
    let lineWidth: CGFloat = 0.5

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let columnWidth = width / CGFloat(columns)
                
                for i in 1 ..< columns {
                    let x = CGFloat(i) * columnWidth
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: height))
                }
            
                let rows = Int(height / rowHeight)
                if rows > 0 {
                    for i in 1 ..< rows {
                        let y = CGFloat(i) * rowHeight
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: width, y: y))
                    }
                }
            }
            .stroke(color, style: .init(lineWidth: lineWidth, lineCap: .round, lineJoin: .miter, miterLimit: 0, dash: [4, 4], dashPhase: 0))
        }
        .allowsHitTesting(false)
    }
}
