//
//  QuestionOfTodaySettingView.swift
//  LTApp
//
//  Created by Renjun Li on 2026/2/4.
//

import SwiftUI

struct QuestionOfTodaySettingView: View {
    @EnvironmentObject var homeCoordinator: HomeCoordinator
    
    var body: some View {
        Text("QuestionOfTodaySettingView")
            .defaultNavigationBar("QuestionOfTodaySettingView") {
                homeCoordinator.pop()
            }
            .defaultBackground()
    }
}
