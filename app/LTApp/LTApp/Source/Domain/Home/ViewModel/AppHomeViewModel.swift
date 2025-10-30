//
//  LTApp, This code is protected by intellectual property rights.
//

import Combine
import SwiftUI

@MainActor
class AppHomeViewModel: ObservableObject {
     var tabbarViewModel = AppTabbarViewModel(
        items: [
        .init(
            selectedIcon: Image(.calendar),
            deselectedIcon: Image(.deselectedCalendar),
            selectedOpacity: 0
        ),
        .init(
            selectedIcon: Image(.threads),
            deselectedIcon: Image(.deselectedThread),
            selectedOpacity: 0
        ),
        .init(
            selectedIcon: Image(.insights),
            deselectedIcon: Image(.deselectedInsights),
            selectedOpacity: 0
        ),
        .init(
            selectedIcon: Image(.user),
            deselectedIcon: Image(.deselectedUser),
            selectedOpacity: 0
        )
    ])
    let contentViewModel: AppScrollContentViewModel
    
    deinit {
        print("AppHomeViewModel-deinit")
    }
    
    init(service: any AppDataWithAuthorizationServiceful) {
        contentViewModel = AppScrollContentViewModel(service: service)
        
        contentViewModel.didScroll = { [weak self] progress, isToRight in
            guard let self else { return }
            print("AppHomeViewModel-progress:\(progress)")
            self.tabbarViewModel.updateOpacity(progress, isToRight: isToRight)
        }
        contentViewModel.didEndScroll = { [weak self] index in
            guard let self else { return }
            print("AppHomeViewModel-didEndScroll:\(index)")
            self.tabbarViewModel.updateSelectedIndex(index)
        }
        tabbarViewModel.didTap = { [weak self] index in
            guard let self else { return }
            self.contentViewModel.scrollTo(index)
        }
    }
}
