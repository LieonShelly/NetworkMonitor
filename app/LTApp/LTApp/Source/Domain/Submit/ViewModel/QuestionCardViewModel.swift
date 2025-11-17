//
//  LTApp, This code is protected by intellectual property rights.
//

import Combine
import Foundation

@MainActor
final class QuestionCardViewModel: ObservableObject, @unchecked Sendable {
    let id: UUID = UUID()
    let question: Question
    var index: Int
    let count: Int
    var maxTranslationWidth: CGFloat? = nil
    var changeToNext: ((Int) -> Void)?
    @Published var rotation: Int = 0
    @Published var offset: CGFloat = .zero
    @Published var viewSize: CGSize = .zero
    @Published var randomAnge: CGFloat = 2
    
    init(question: Question,
         index: Int,
         count: Int,
         visibleCardsCount: Int = 3,
         maxTranslationWidth: CGFloat? = nil,
         changeToNext: ((Int) -> Void)? = nil) {
        self.question = question
        self.index = index
        self.count = count
        self.maxTranslationWidth = maxTranslationWidth
        self.changeToNext = changeToNext
    }
    
    func next() {
        rotation += 1
        changeToNext?(rotation)
    }
}
