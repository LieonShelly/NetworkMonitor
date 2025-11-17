//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

struct LoopingStackCardView<Content: View>: View {
    var index: Int
    let count: Int
    let visibleCardsCount: Int
    @Binding var rotation: Int
    var maxTranslationWidth: CGFloat? = nil
    @Binding var didRefresh: Int
    @ViewBuilder var content: Content
    @State private var offset: CGFloat = .zero
    @State private var viewSize: CGSize = .zero
    @State private var randomAnge: CGFloat = 2
    
    init(
        index: Int,
        count: Int,
        visibleCardsCount: Int,
        maxTranslationWidth: CGFloat? = nil,
        rotation: Binding<Int>,
        didRefresh: Binding<Int>,
        @ViewBuilder content: (() -> Content)
    ) {
        self.index = index
        self.count = count
        self.visibleCardsCount = visibleCardsCount
        self.maxTranslationWidth = maxTranslationWidth
        self._didRefresh = didRefresh
        self.content = content()
        self._rotation = rotation
    }
    
    var body: some View {
        let rotationDegree: CGFloat = -10
        let rotation = max(min(-offset / viewSize.height, 1), 0) * rotationDegree
        content
            .onGeometryChange(for: CGSize.self, of: {
                $0.size
            }, action: {
                viewSize = $0
            })
            .animation(.smooth(duration: 0.5, extraBounce: 0), value: randomAnge)
            .offset(y: offset)
            .rotationEffect(.degrees(randomAnge * CGFloat(index)), anchor: .center)
            .rotation3DEffect(.degrees(-rotation), axis: (1, 0, 0), anchor: .center, perspective: 0.5)
          
            .gesture(
                DragGesture()
                    .onChanged({ value in
                        let xOffset = -max(-value.translation.height, 0)
                        if let maxTranslationWidth {
                            let progress = -max(min(-xOffset / maxTranslationWidth, 1), 0) * viewSize.height
                            offset = progress
                        } else {
                            offset = xOffset
                        }
                      
                    })
                    .onEnded({ value in
                        let xVelocity = max(-value.velocity.height /  5, 0)
                        if (-offset + xVelocity) > viewSize.height * 0.65 {
                            print("Push to next card")
                            pushToNextCard()
                        } else {
                            withAnimation(.smooth(duration: 0.3, extraBounce: 0)) {
                                offset = .zero
                            }
                        }
                    }),
                isEnabled: index == 0 && count > 1
            )
            .onTapGesture {
                pushToNextCard()
            }
    }
    
    private func pushToNextCard() {
        withAnimation(.smooth(duration: 0.5, extraBounce: 0).logicallyComplete(after: 0.5), completionCriteria: .logicallyComplete) {
            offset = -viewSize.height
         
        } completion: {
            rotation += 1
            withAnimation(.smooth(duration: 0.25, extraBounce: 0)) {
                offset = .zero
            }
        }
    }
}

extension SubviewsCollection {
   
    func rotateFromLeft(by: Int) -> [SubviewsCollection.Element] {
        let moveIndex = by % count
        let rotatedElements = Array(self[moveIndex...]) + Array(self[0 ..< moveIndex])
        return rotatedElements
    }
}

extension [SubviewsCollection.Element] {
    func index(_ item: SubviewsCollection.Element) -> Int {
        firstIndex(where: { $0.id == item.id }) ?? 0
    }
}
