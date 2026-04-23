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
    var goToQoTFlow: (() -> Void)?
    @Published var preProgress: CGFloat = 0
    @Published var isTapping: Bool = false
    let calendarViewModel: CalendarViewModel
    let threadViewModel: ThreadViewModel
    let userViewModel: NewUserHomeViewModel
    let insightsViewModel: InsightsViewModel
    
    init(service: any AppDataWithAuthorizationServiceful, ) {
        calendarViewModel = CalendarViewModel(service: service)
        threadViewModel = ThreadViewModel(service: service)
        userViewModel = NewUserHomeViewModel(dataService: service)
        insightsViewModel = InsightsViewModel(dataService: service)
    }
    
    func configQoTFlow(goToQoTFlow: (() -> Void)? = nil) {
        insightsViewModel.goToQoTFlow = goToQoTFlow
    }
    
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
        didEndScroll?(Int(preProgress.rounded()))
    }
    
    private func updateProgress(_ value: CGFloat) {
        self.preProgress = value
    }
}
