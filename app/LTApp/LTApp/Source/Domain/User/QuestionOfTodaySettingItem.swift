//
//  QuestionOfTodaySettingItem.swift
//  LTApp
//
//  Created by Renjun Li on 2026/2/9.
//

import Foundation
import SwiftUI

public struct QuestionOfTodaySettingItem: Sendable {
    let selected: Bool
    let disabled: Bool
    let title: String
    let description: String
    var id: UUID = UUID()
    let qodStrategyValue: String
    let svgIconURL: String?
    
    public init(selected: Bool, disabled: Bool, title: String, description: String, id: UUID, qodStrategyValue: String, svgIconURL: String?) {
        self.selected = selected
        self.title = title
        self.description = description
        self.id = id
        self.qodStrategyValue = qodStrategyValue
        self.svgIconURL = svgIconURL
        self.disabled = disabled
    }
    
    public func copyWith(selected: Bool? = nil, id: UUID = UUID()) -> QuestionOfTodaySettingItem {
        QuestionOfTodaySettingItem(
            selected: selected ?? self.selected,
            disabled: disabled,
            title: title,
            description: description,
            id: id,
            qodStrategyValue: qodStrategyValue,
            svgIconURL: svgIconURL
        )
    }
}
