//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//


import Foundation

public struct Question: Sendable, Equatable, Hashable {
    public var id: String
    var title: String
    var pinned: Bool = false
    var category: Category?
    
    public init(id: String, title: String, pinned: Bool = false, category: Category? = nil) {
        self.id = id
        self.title = title
        self.pinned = pinned
        self.category = category
    }
    
    
}
