//
//  QuestionOfTodaySettingView.swift
//  LTApp
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
        ContainerWithFixedHeader {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: .zero) {
                    Text("Everyday, ask me...")
                        .textStyle(font: .heading, color: AppColor.black)
                    
                    Text("Set up your daily sparks")
                        .textStyle(font: .caption, color: AppColor.greyMedium)
                        .padding(.top, 6)
                    
                    VStack(spacing: 16) {
                        ForEach(viewModel.list, id: \.id) { item in
                            strategyRow(item)
                        }
                    }
                    .padding(.top, 24)
                }
                .padding(.horizontal, 32)
            }
            
            DefaultAppButton(
                isEnabled: viewModel.hasChanges && !viewModel.isSaving,
                title: "Save"
            ) {
                Task {
                    await viewModel.save()
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .toolbarVisibility(.hidden, for: .navigationBar)
        .defaultBackground()
        .task {
            try? await viewModel.fetchData()
        }
    }
    
    private func strategyRow(_ item: QuestionOfTodaySettingItem) -> some View {
        let isSelected = viewModel.selectedValue == item.qodStrategyValue
        let textColor = item.disabled ? AppColor.greyMedium : AppColor.black
        
        return VStack(alignment: .leading, spacing: .zero) {
            HStack(alignment: .top) {
                SVGImageView(url: item.svgIconURL ?? "", renderMode: .template)
                    .foregroundStyle(textColor)
                    .frame(width: 32, height: 32)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(AppColor.black)
                }
            }
            
            Text(item.title)
                .textStyle(size: 16, color: textColor, fontFamily: .poppinsRegular)
                .padding(.top, 8)
            
            Text(item.description)
                .textStyle(font: .caption, color: AppColor.greyMedium)
                .padding(.top, 4)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? AppColor.black : AppColor.greyLight, lineWidth: isSelected ? 2 : 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            guard !item.disabled else { return }
            withAnimation(.easeInOut(duration: 0.15)) {
                viewModel.select(item)
            }
        }
    }
}
