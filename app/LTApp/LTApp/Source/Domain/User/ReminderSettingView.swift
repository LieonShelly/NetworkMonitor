//
//  ReminderSettingView.swift
//  LTApp
//

import SwiftUI
import UIComponent

struct ReminderSettingView: View {
    @EnvironmentObject var homeCoordinator: HomeCoordinator
    @StateObject var viewModel: ReminderSettingViewModel
    
    var body: some View {
        ContainerWithFixedHeader {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: .zero) {
                    Text("Whisper to me at...")
                        .textStyle(font: .heading, color: AppColor.black)
                
                    Text("Your daily journal reminder")
                        .textStyle(font: .caption, color: AppColor.greyMedium)
                        .padding(.top, 6)
                    
                    HStack {
                        Text("Daily reminder")
                            .textStyle(size: 14, color: AppColor.black, fontFamily: .poppinsRegular)
                        Spacer()
                        Toggle("", isOn: $viewModel.isEnabled)
                            .labelsHidden()
                            .tint(AppColor.black)
                    }
                    .padding(.top, 24)
                    
                    if viewModel.isEnabled {
                        VStack(spacing: 16) {
                            ForEach(viewModel.slots, id: \.slot) { item in
                                slotRow(item.slot, label: item.label)
                            }
                        }
                        .padding(.top, 16)
                        .transition(.opacity)
                    }
                }
                .padding(.horizontal, 32)
                .animation(.easeInOut(duration: 0.2), value: viewModel.isEnabled)
            }
            
            if viewModel.isEnabled {
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
                .transition(.opacity)
            }
        }
        .defaultBackground()
        .toolbarVisibility(.hidden, for: .navigationBar)
        .onFirstAppear {
            Task {
                await viewModel.fetchReminder()
            }
        }
    }
    
    private func slotRow(_ slot: ReminderSlot, label: String) -> some View {
        let isSelected = viewModel.selectedSlot == slot
        
        return HStack {
            Text(label)
                .textStyle(size: 16, color: AppColor.black, fontFamily: .poppinsRegular)
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(AppColor.black)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? AppColor.black : AppColor.greyLight, lineWidth: isSelected ? 2 : 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.15)) {
                viewModel.selectedSlot = slot
            }
        }
    }
}
