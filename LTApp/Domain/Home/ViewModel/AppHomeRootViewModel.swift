//
//  LTApp, This code is protected by intellectual property rights.
//

import Combine

final class AppHomeRootViewModel: ObservableObject, @unchecked Sendable {
    @Published var overLayData: FirstQuestionSubmittedData?
    
    init(overLayData: FirstQuestionSubmittedData?) {
        self.overLayData = overLayData
    }
    
}
