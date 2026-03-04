//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

public struct WavyLine: Shape {
    let segmentCount: Int
    let seed: Int
    let axis: Axis
    
    public init(segmentCount: Int, seed: Int, axis: Axis = .vertical) {
        self.segmentCount = segmentCount
        self.seed = seed
        self.axis = axis
    }
    
    public func path(in rect: CGRect) -> Path {
        switch axis {
        case .horizontal:
            horizontal(in: rect)
        case .vertical:
            vertical(in: rect)
        }
    }
    
    func vertical(in rect: CGRect) -> Path {
        var path = Path()
        var random = SeededGenerator(seed: seed)
        
        var y: CGFloat = rect.minY
        let step = rect.height / CGFloat(segmentCount)
        
        path.move(to: CGPoint(x: rect.midX, y: y))
        
        for _ in 0..<segmentCount {
            let isWave = Bool.random(using: &random)
            let nextY = y + step
            
            if isWave {
                let amplitude: CGFloat = CGFloat.random(in: 1...3, using: &random)
                let controlY = y + step / 2
                let direction: CGFloat = Bool.random(using: &random) ? 1 : -1
                
                path.addQuadCurve(
                    to: CGPoint(x: rect.midX, y: nextY),
                    control: CGPoint(x: rect.midX + amplitude * direction, y: controlY)
                )
            } else {
                path.addLine(to: CGPoint(x: rect.midX, y: nextY))
            }
            
            y = nextY
        }
        
        return path
    }
    
    func horizontal(in rect: CGRect) -> Path {
        var path = Path()
        var random = SeededGenerator(seed: seed)
        
        var x: CGFloat = rect.minX
        let step = rect.width / CGFloat(segmentCount)
        
        path.move(to: CGPoint(x: x, y: rect.midY))
        
        for _ in 0..<segmentCount {
            let isWave = Bool.random(using: &random)
            let nextX = x + step
            
            if isWave {
                let amplitude: CGFloat = CGFloat.random(in: 1...3, using: &random)
                let controlX = x + step / 2
                let direction: CGFloat = Bool.random(using: &random) ? 1 : -1
                
                path.addQuadCurve(
                    to: CGPoint(x: nextX, y: rect.midY),
                    control: CGPoint(x: controlX, y: rect.midY + amplitude * direction)
                )
            } else {
                path.addLine(to: CGPoint(x: nextX, y: rect.midY))
            }
            
            x = nextX
        }
        
        return path
    }
}

public struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: Int) {
        self.state = UInt64(seed)
    }

    mutating public func next() -> UInt64 {
        state = 6364136223846793005 &* state &+ 1
        return state
    }
}

struct ContentView1: View {
    var body: some View {
        WavyLine(segmentCount: 100, seed: 1000)
            .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round))
            .foregroundColor(AppColor.color(hex: 0x000000))
            .padding()
    }
}


