//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public struct Category: Sendable, Identifiable, Equatable, Hashable {
    public var id: String
    public var name: String
    public var questions: [Question]
    public let imageUrl: String
    
    public init(id: String, name: String, questions: [Question], imageUrl: String) {
        self.id = id
        self.name = name
        self.questions = questions
        self.imageUrl = imageUrl
    }
    
    public static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
    }
}

