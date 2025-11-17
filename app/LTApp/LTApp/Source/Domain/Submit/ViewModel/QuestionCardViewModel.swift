//
//  LTApp, This code is protected by intellectual property rights.
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class QuestionCardViewModel: ObservableObject, @unchecked Sendable {
    let id: UUID = UUID()
    let question: Question
    var index: Int
    let count: Int
    var maxTranslationWidth: CGFloat? = nil
    var changeToNext: (() -> Void)?
    @Published var offset: CGFloat = .zero
    @Published var viewSize: CGSize = .zero
    @Published var randomAnge: CGFloat = 2
    
    init(question: Question,
         index: Int,
         count: Int,
         visibleCardsCount: Int = 3,
         maxTranslationWidth: CGFloat? = nil,
         changeToNext: (() -> Void)? = nil) {
        self.question = question
        self.index = index
        self.count = count
        self.maxTranslationWidth = maxTranslationWidth
        self.changeToNext = changeToNext
    }
    
    deinit {
        print("deinit")
    }
    
    func next() {
        changeToNext?()
    }
    
    
    func pushToNextCard() {
        withAnimation(.smooth(duration: 0.5, extraBounce: 0).logicallyComplete(after: 0.5), completionCriteria: .logicallyComplete) {
            self.offset = -self.viewSize.height
        } completion: {
            self.next()
            withAnimation(.smooth(duration: 0.25, extraBounce: 0)) {
                self.offset = .zero
            }
        }
    }
}
