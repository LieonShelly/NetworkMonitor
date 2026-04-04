//
//  LTApp, This code is protected by intellectual property rights.
//

import Combine

final class WelcomeViewModel: ObservableObject, @unchecked Sendable {
    
    private(set) var category: Category
    
    init(category: Category) {
        self.category = category
    }
}
