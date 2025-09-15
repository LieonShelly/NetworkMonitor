//
//  LTApp, This code is protected by intellectual property rights.
//

import Combine
import SwiftUI

class AppScrollContentViewModel: ObservableObject {
    @Published var scrollPostion: ScrollPosition = .init(id: 0)
    var didScroll: ((_ progress: CGFloat, _ isToRight: Bool) -> Void)?
    var didEndScroll: ((Int) -> Void)?
    @Published var preProgress: CGFloat = 0
    
    deinit {
        print("AppScrollContentViewModel-deinit")
    }
    
    func scrollTo(_ index: Int) {
        withAnimation(.easeInOut) {
            scrollPostion = .init(id: index)
        }
    }
    
    func updateScrollProgress(_ scrollProgress: CGFloat) {
        let isToRight = scrollProgress > preProgress
        didScroll?(scrollProgress, isToRight)
        preProgress = scrollProgress
    }
    
    func updateSelectedIndex() {
        didEndScroll?(Int(preProgress))
    }
}
