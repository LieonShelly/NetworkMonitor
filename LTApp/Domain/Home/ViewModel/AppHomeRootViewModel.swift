//
//  LTApp, This code is protected by intellectual property rights.
//

import Combine

final class AppHomeRootViewModel: ObservableObject, @unchecked Sendable {
    @Published var showOverlay: Bool = false
    @Published var overLayData: FirstQuestionSubmittedData
    
    init(showOverlay: Bool, overLayData: FirstQuestionSubmittedData) {
        self.showOverlay = showOverlay
        self.overLayData = overLayData
    }
    
}
