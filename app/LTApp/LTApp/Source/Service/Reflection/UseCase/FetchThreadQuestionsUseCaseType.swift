//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public protocol FetchThreadQuestionsUseCaseType: Sendable {
    func execute() async throws -> [ThreadQuestionItem]
}

public enum ThreadAnswerItemType: Sendable {
    case noraml(Answer)
    case placeholder
    case addBtn
    
  
}

public struct ThreadAnswerItem: Sendable, Identifiable {
    let type: ThreadAnswerItemType
    
    public var id: String = UUID().uuidString
}


public struct ThreadQuestionItem: Sendable {
    let id: String
    let title: String
    var answerItems: [ThreadAnswerItem]
    var hasExactDivided: Bool =  false
    
    func toQuestion() -> Question {
        .init(id: id, title: title, pinned: true)
    }

}

extension ThreadQuestion {
    func toThreadItem() -> ThreadQuestionItem {
        ThreadQuestionItem(id: id, title: title, answerItems: answers.map { .init(type: .noraml($0))})
    }
}

public class FetchThreadQuestionsUseCase: FetchThreadQuestionsUseCaseType, @unchecked Sendable {
    private let repository: any ReflectionRepositoryType
    
    public init(repository: any ReflectionRepositoryType) {
        self.repository = repository
    }
    
    public func execute() async throws -> [ThreadQuestionItem] {
        let questions = try await repository.fetchThreadPinnedQuestions()
        let column: Float = 7
        var items = questions.map { $0.toThreadItem() }
        for index in ( 0 ..< items.count) {
            var item = items[index]
            let answerCount = item.answerItems.count
            let remainnings =  column - Float(answerCount).truncatingRemainder(dividingBy: column)
            
            if Int(remainnings) == Int(column) {
                item.hasExactDivided = true
            } else {
                var answerItems = item.answerItems
                var placeholderCount = 6
                if remainnings > 0 {
                    placeholderCount = Int(remainnings) - 1
                }
                for _ in (0 ..< placeholderCount) {
                    answerItems.append(.init(type: .placeholder))
                }
                answerItems.append(.init(type: .addBtn))
                item.answerItems = answerItems
            }
           
            items[index] = item
        }
        return items
    }
}
