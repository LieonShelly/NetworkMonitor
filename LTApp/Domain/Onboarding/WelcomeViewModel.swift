//
//  LTApp, This code is protected by intellectual property rights.
//

import Combine

final class WelcomeViewModel: ObservableObject, @unchecked Sendable {
    
    private(set) var categoryId: String
    
    init(categoryId: String) {
        self.categoryId = categoryId
    }
    
}
