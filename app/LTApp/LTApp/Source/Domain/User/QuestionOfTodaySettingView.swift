//
//  QuestionOfTodaySettingView.swift
//  LTApp
//
//  Created by Renjun Li on 2026/2/4.
//

import SwiftUI
import UIComponent

struct QuestionOfTodaySettingView: View {
    @EnvironmentObject var homeCoordinator: HomeCoordinator
    @StateObject var viewModel: QuestionOfTodaySettingViewModel
    
    
    init(viewModel: QuestionOfTodaySettingViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView(content: {
            VStack {
                Text("Question of the day is a daily prompter to guide your reflection. Manage your preferred question sets inside to better serve your inspiration.")
                    .textStyle(size: 13, color: AppColor.color(hex: 0x6f6f6f), fontFamily: .poppinsRegular)
                    .padding(.top, 6)
                
                VStack(spacing: 16) {
                    ForEach(viewModel.list, id: \.id) { item in
                        row(item)
                    }
                }
                .padding(.top, 20)
            }
            .padding(.horizontal, 36)
            
          
        })
            .defaultNavigationBar("Question of the Day") {
                homeCoordinator.pop()
            }
            .defaultBackground()
            .task {
                await viewModel.fetchData()
            }
    }
    
    func row(_ item: QuestionOfTodaySettingItem) -> some View {
        VStack(alignment: .leading, spacing: .zero) {
            HStack {
                Image(item.icon)
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(item.selected ? AppColor.color(hex: 0x000000) : AppColor.color(hex: 0x6f6f6f))
                    .frame(width: 32, height: 32)
                
                Spacer()
                
                Image(item.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
            }
            
            Text(item.title)
                .textStyle(size: 16, color: item.selected ? AppColor.color(hex: 0x000000) : AppColor.color(hex: 0x6f6f6f), fontFamily: .poppinsRegular)
                .padding(.top, 7)
            
            Text(item.description)
                .textStyle(size: 13, color: AppColor.color(hex: 0x6F6F6F), fontFamily: .poppinsRegular)
                .padding(.top, 4)
            
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(style: .init(lineWidth: 1))
                .foregroundStyle(item.selected ? AppColor.color(hex: 0x1E1E1E) : AppColor.color(hex: 0x6f6f6f))
        )
    }
}
