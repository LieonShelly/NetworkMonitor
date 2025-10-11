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
            icon: Image(.calendar),
              normalColor: .white,
            selectedColor: .red,
            selectedOpacity: 0
        ),
        .init(
            icon: Image(.threads),
            normalColor: .white,
            selectedColor: .red,
            selectedOpacity: 0
        )
    ])
    let contentViewModel: AppScrollContentViewModel
    
    init(service: any AppDataWithAuthorizationServiceful) {
        contentViewModel = AppScrollContentViewModel(service: service)
        
        contentViewModel.didScroll = { [weak self] progress, isToRight in
            guard let self else { return }
            self.tabbarViewModel.updateOpacity(progress, isToRight: isToRight)
        }
        contentViewModel.didEndScroll = { [weak self] index in
            guard let self else { return }
            self.tabbarViewModel.updateSelectedIndex(index)
        }
        tabbarViewModel.didTap = { [weak self] index in
            guard let self else { return }
            self.contentViewModel.scrollTo(index)
        }
    }
}
