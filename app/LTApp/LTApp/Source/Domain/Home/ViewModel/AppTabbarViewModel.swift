//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
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
                selectedIcon: $0.selectedIcon,
                deselectedIcon: $0.deselectedIcon,
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
        if isToRight {
            let value = Math.normalize(value: value, lowerBound: CGFloat(selectedIndex), upperBound: CGFloat(selectedIndex) + 1.0)
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
            let value = Math.normalize(value: value, lowerBound: CGFloat(selectedIndex - 1), upperBound: CGFloat(selectedIndex))
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


struct Math {
    static func normalize(value: CGFloat, lowerBound: CGFloat, upperBound: CGFloat) -> CGFloat {
        guard upperBound != lowerBound else { return 0 }
        return (value - lowerBound) / (upperBound - lowerBound)
    }
}
