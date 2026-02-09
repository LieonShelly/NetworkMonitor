//
//  QuestionOfTodaySettingItem.swift
//  LTApp
//
//  Created by Renjun Li on 2026/2/9.
//

import Foundation
import SwiftUI

struct QuestionOfTodaySettingItem: Sendable {
    let icon: ImageResource
    let selected: Bool
    let title: String
    let description: String
    var id: UUID = UUID()
    let qodStrategy: QodStrategy
    
    func copyWith(selected: Bool? = nil) -> QuestionOfTodaySettingItem {
        QuestionOfTodaySettingItem(icon: icon, selected: selected ?? self.selected, title: title, description: description, qodStrategy: qodStrategy)
    }
}
