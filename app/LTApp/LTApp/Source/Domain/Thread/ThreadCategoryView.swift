//
//  ThreadCategoryView.swift
//  LTApp
//
//  Created by Renjun Li on 2026/2/3.
//

import SwiftUI
import UIComponent

struct ThreadCategoryItem: Identifiable {
    var id: UUID = UUID()
    let category: Category
    var selected: Bool
    
    init(id: UUID = UUID(), category: Category, selected: Bool) {
        self.category = category
        self.selected = selected
        self.id = id
    }
    
    func copyWith(selected: Bool) -> ThreadCategoryItem {
        return ThreadCategoryItem(id: id, category: category, selected: selected)
    }
}

struct ThreadCategoryView: View {
    let items: [ThreadCategoryItem]
    
    var body: some View {
        let count = Int(items.count)
        HStack(spacing: .zero) {
            ForEach(0 ..< count, id: \.self) { index in
                let category = items[index]
                item(category)
                if index < items.count {
                    Spacer()
                }
            }
        }
        .frame(height: 60)
       
    }
    
    func item(_ category: ThreadCategoryItem) -> some View {
        VStack(spacing: 8) {
            DefaultThumbnailIconImageView(url: category.category.imageUrl)
            
            Text(category.category.name)
                .textStyle(
                    size: 16,
                    color: category.selected ? AppColor.color(hex: 0x000000) : AppColor.color(hex: 0xB8B8B8),
                    fontFamily: .feltTipSeniorRegular
                )
            
        }
    }
}
