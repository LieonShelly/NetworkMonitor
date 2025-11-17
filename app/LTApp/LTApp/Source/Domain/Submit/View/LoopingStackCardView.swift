//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

struct LoopingStackCardView: View {
    @ObservedObject var viewModel: QuestionCardViewModel
    
    init(viewModel: QuestionCardViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        let rotationDegree: CGFloat = -10
        let rotation = max(min(-viewModel.offset / viewModel.viewSize.height, 1), 0) * rotationDegree
        content
            .onGeometryChange(for: CGSize.self, of: {
                $0.size
            }, action: {
                viewModel.viewSize = $0
            })
            .animation(.smooth(duration: 0.5, extraBounce: 0), value: viewModel.randomAnge)
            .offset(y: viewModel.offset)
            .rotationEffect(.degrees(viewModel.randomAnge * CGFloat(viewModel.index)), anchor: .center)
            .rotation3DEffect(.degrees(-rotation), axis: (1, 0, 0), anchor: .center, perspective: 0.5)
          
            .gesture(
                DragGesture()
                    .onChanged({ value in
                        let yOffset = -max(-value.translation.height, 0)
                        if let maxTranslationWidth = viewModel.maxTranslationWidth {
                            let progress = -max(min(-yOffset / maxTranslationWidth, 1), 0) * viewModel.viewSize.height
                            viewModel.offset = progress
                        } else {
                            viewModel.offset = yOffset
                        }
                      
                    })
                    .onEnded({ value in
                        let yVelocity = max(-value.velocity.height /  5, 0)
                        if (-viewModel.offset + yVelocity) > viewModel.viewSize.height * 0.2 {
                            print("Push to next card")
                            pushToNextCard()
                        } else {
                            withAnimation(.smooth(duration: 0.3, extraBounce: 0)) {
                                viewModel.offset = .zero
                            }
                        }
                    })
            )
            .onTapGesture {
                pushToNextCard()
            }
    }
    
    private func pushToNextCard() {
        withAnimation(.smooth(duration: 0.5, extraBounce: 0).logicallyComplete(after: 0.5), completionCriteria: .logicallyComplete) {
            viewModel.offset = -viewModel.viewSize.height
         
        } completion: {
            viewModel.next()
            withAnimation(.smooth(duration: 0.25, extraBounce: 0)) {
                viewModel.offset = .zero
            }
        }
    }
    
    var content: some View {
        QuestionCardView(question: viewModel.question)
//            .zIndex(realIndex)
//            .rotationEffect(.degrees((2.0 ) * CGFloat(index)), anchor: .init(x: 0, y: 0.5))
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
