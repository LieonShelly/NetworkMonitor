//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

struct WavyLine: Shape {
    let segmentCount: Int
    let seed: Int
    
    func path(in rect: CGRect) -> Path {
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
}

struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: Int) {
        self.state = UInt64(seed)
    }

    mutating func next() -> UInt64 {
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


