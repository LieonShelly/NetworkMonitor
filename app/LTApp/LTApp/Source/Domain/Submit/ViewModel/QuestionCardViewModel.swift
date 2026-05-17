//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Combine
import Foundation
import SwiftUI

final class QuestionCardViewModel: ObservableObject, @unchecked Sendable {
    let id: UUID = UUID()
    let question: Question
    @Published var index: Int
    let count: Int
    var maxTranslationWidth: CGFloat? = nil
    var changeToNext: ( @MainActor () -> Void)?
    @Published var offset: CGFloat = .zero
    @Published var viewSize: CGSize = .zero
    @Published var randomAnge: CGFloat = 4
    
    init(question: Question,
         index: Int,
         count: Int,
         visibleCardsCount: Int = 3,
         maxTranslationWidth: CGFloat? = nil,
         changeToNext: (  (@MainActor () -> Void))? = nil) {
        self.question = question
        self.index = index
        self.count = count
        self.maxTranslationWidth = maxTranslationWidth
        self.changeToNext = changeToNext
    }
    
    deinit {
        print("QuestionCardViewModel-deinit")
    }
    
    @MainActor
    func next() {
        changeToNext?()
    }
    
    
    @MainActor
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
