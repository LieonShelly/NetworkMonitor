//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation
import Combine

class AppTabbarViewModel: ObservableObject {
    @Published private(set) var items: [AppTabbarItem]
    private(set) var selectedIndex: Int = 0
    var didTap: ((Int) -> Void)?
    
    init(items: [AppTabbarItem]) {
        self.items = items
    }
    
    func didTapTabrItem(_ item: AppTabbarItem, needNotify: Bool = true) {
        guard !item.isSelected else { return }
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        var newItem = item
        newItem.selectedOpacity = 1.0
        
        let newItems = items.map {
            AppTabbarItem(
                id: $0.id,
                icon: $0.icon,
                normalColor: $0.normalColor,
                selectedColor: $0.selectedColor,
                selectedOpacity: 0
            )}
        items = newItems
        items[index] = newItem
        selectedIndex = index
        if needNotify {
            didTap?(index)
        }
    }
    
    func updateOpacity(_ value: CGFloat, isToRight: Bool) {
        let value = min(1, max(value, 0))
        if isToRight {
            let currentIndex = selectedIndex
            let destIndex = currentIndex + 1
            guard destIndex < items.count else { return }
            var cureentItem = items[currentIndex]
            var destItem = items[destIndex]
            
            cureentItem.selectedOpacity = 1 - value
            destItem.selectedOpacity = value
            items[currentIndex] = cureentItem
            items[destIndex] = destItem
        } else {
            let currentIndex = selectedIndex
            let destIndex = currentIndex - 1
            guard destIndex >= 0 else { return }
            var cureentItem = items[currentIndex]
            var destItem = items[destIndex]
            
            cureentItem.selectedOpacity = value
            destItem.selectedOpacity = 1 - value
            items[currentIndex] = cureentItem
            items[destIndex] = destItem
        }
    }
    
    func updateSelectedIndex(_ index: Int) {
        guard index < items.count else { return }
        selectedIndex = index
        let item = items[selectedIndex]
        didTapTabrItem(item, needNotify: false)
    }
}
