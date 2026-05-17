//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import SwiftUI

public struct AnimatedMultilineText: View {
    let text: String
    let font: UIFont
    var textColor: Color = AppColor.textPrimary
    let animationDuration: Double = 0.5
    let characterDelay: Double = 0.05
    let lineBreakDelay: Double = 0.12
    let alignment: TextAlignment = .center
    let animationCompleted: (() -> Void)
    private let width: CGFloat
    private var lines: [String] = []
  
    @State private var visibleLines = 0
    
    public init(text: String, font: UIFont, width: CGFloat, animationCompleted: @escaping (() -> Void) = {}) {
        self.text = text
        self.font = font
        self.width = width
        self.animationCompleted = animationCompleted
        self.lines = breakTextIntoLines(text, font: font, width: width)
    }
    
    public var body: some View {
        VStack(spacing: .zero) {
            ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                HStack(spacing: .zero) {
                    ForEach(Array(line.enumerated()), id: \.offset) { charIndex, char in
                        Text(String(char))
                            .font(Font(font))
                            .foregroundStyle(textColor)
                            .offset(y: visibleLines > index ? 0 : 25)
                            .opacity(visibleLines > index ? 1 : 0)
                            .animation(
                                .spring(duration: animationDuration)
                                .delay(delayDuration(currentRowIndex: index, charIndex: charIndex)),
                            value: visibleLines
                        )
                    }
                }
            }
        }
        .frame(width: width)
        .task {
            visibleLines = lines.count
            if let lastLine = lines.last {
                let lastRowIndex = lines.count - 1
                let lastCharIndex = lastLine.count - 1
                let lastDelay = delayDuration(currentRowIndex: lastRowIndex, charIndex: lastCharIndex)
                let totalDuration = lastDelay + animationDuration
                try? await Task.sleep(for: .seconds(totalDuration))
                animationCompleted()
               
            }
        }
    }

    func breakTextIntoLines(_ text: String, font: UIFont, width: CGFloat) -> [String] {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font
        ]
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let framesetter = CTFramesetterCreateWithAttributedString(attributedString as CFAttributedString)
        
        let path = CGMutablePath()
        path.addRect(CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude))
        
        let frame = CTFramesetterCreateFrame(framesetter, CFRange(location: 0, length: attributedString.length), path, nil)
        
        let lines = CTFrameGetLines(frame) as! [CTLine]
        var lineStrings: [String] = []
        
        for line in lines {
            let lineRange = CTLineGetStringRange(line)
            let range = NSRange(location: lineRange.location, length: lineRange.length)
            let lineString = (text as NSString).substring(with: range)
            lineStrings.append(lineString)
        }
        
        return lineStrings
    }
    
    func delayDuration(currentRowIndex: Int, charIndex: Int) -> Double {
        let preLinesDuration: Double = lines[0 ..< currentRowIndex].reduce(0) { total, line in
            return total + lineBreakDelay + characterDelay * Double(line.count)
        }
        let currentColumnDuration = Double(charIndex) * characterDelay
        return preLinesDuration + currentColumnDuration
    }
}
