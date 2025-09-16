//
//  LTApp, This code is protected by intellectual property rights.
//

import Combine
import SwiftUI

@MainActor
class AppScrollContentViewModel: ObservableObject {
    @Published var scrollPosition: ScrollPosition = .init(id: 0)
    var didScroll: ((_ progress: CGFloat, _ isToRight: Bool) -> Void)?
    var didEndScroll: ((Int) -> Void)?
    @Published var preProgress: CGFloat = 0
    @Published var isTapping: Bool = false
    deinit {
        print("AppScrollContentViewModel-deinit")
    }
    
    func scrollTo(_ index: Int) {
        scrollPosition = .init(id: index)
    }
    
    func updateScrollProgress(_ scrollProgress: CGFloat) {
        let isToRight = scrollProgress > preProgress
        didScroll?(scrollProgress, isToRight)
        preProgress = scrollProgress
      
    }
    
    func updateSelectedIndex() {
        didEndScroll?(Int(preProgress))
    }
    
    private func updateProgress(_ value: CGFloat) {
        self.preProgress = value
    }
}
