//
//  LTApp, This code is protected by intellectual property rights.
//

import Combine

final class AppHomeRootViewModel: ObservableObject, @unchecked Sendable {
    @Published var showNotificationView: Bool
    init(showNotificationView: Bool = false) {
        self.showNotificationView = showNotificationView
    }
}
