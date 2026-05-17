//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//
//
//  PersonaSettingView.swift
//  LTApp
//


import SwiftUI
import UIComponent

struct PersonaSettingView: View {
    @StateObject var viewModel: PersonaSettingViewModel

    
    init(viewModel: PersonaSettingViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        ContainerWithFixedHeader {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: .zero) {
                    Text("Talk to me as...")
                        .textStyle(font: .heading, color: AppColor.black)

                    Text("Choose the tone of voice for your insights")
                        .textStyle(font: .caption, color: AppColor.greyMedium)
                        .padding(.top, 6)
                    
                    VStack(spacing: 16) {
                        ForEach(viewModel.personas) { persona in
                            personaRow(persona)
                        }
                    }
                    .frame(maxWidth: .infinity)
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
        .defaultBackground()
        .toolbarVisibility(.hidden, for: .navigationBar)
        .onFirstAppear {
            Task {
                await viewModel.fetchPersonas()
            }
        }
    }
    
    private func personaRow(_ persona: PersonaOption) -> some View {
        let isSelected = viewModel.selectedId == persona.id
        
        return HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(persona.label)
                    .textStyle(size: 16, color: AppColor.black, fontFamily: .poppinsRegular)
                
                if let description = persona.description {
                    Text(description)
                        .textStyle(font: .caption, color: AppColor.greyMedium)
                }
            }
            
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
                viewModel.selectedId = persona.id
            }
        }
    }
}
