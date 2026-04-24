//
//  AboutMeView.swift
//  LTApp
//

import SwiftUI
import UIComponent

struct AboutMeView: View {
    @StateObject var viewModel: AboutMeViewModel
    @FocusState private var isNameFocused: Bool
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    init(viewModel: AboutMeViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ContainerWithFixedHeader {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: .zero) {
                    Text("About me...")
                        .textStyle(font: .heading, color: AppColor.black)
                        .padding(.horizontal, 32)
                    
                    VStack(alignment: .leading, spacing: .zero) {
                        nameSection
                        if isNameFocused {
                            saveButton
                                .padding(.top, 16)
                                .padding(.bottom, 8)
                        }
                        divider
                        
                        emailSection
                        
                        divider
                    }
                    .padding(.horizontal, 32)
                    
                    Button {
                        Task {
                            await viewModel.logout()
                            appCoordinator.changeRoot(.preHome)
                        }
                    } label: {
                        Text("Logout")
                            .textStyle(size: 16, color: AppColor.color(hex: 0xE75C06), fontFamily: .poppinsRegular)
                    }
                    .padding(.top, 24)
                    .padding(.horizontal, 32)
                }
            }
            .defaultBackground()
            .toolbarVisibility(.hidden, for: .navigationBar)
            .animation(.easeInOut, value: isNameFocused)
            .onTapGesture {
                isNameFocused = false
            }
            
            .onFirstAppear {
                Task {
                   try? await viewModel.fetchUserInfo()
                }
            }
            .onChange(of: isNameFocused, { oldvalue, newValue in
                if !newValue && !viewModel.hasChanges {
                    viewModel.nickname = viewModel.displayName
                }
            })
        }
        
    }
    
    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Name")
                .textStyle(font: .caption, color: AppColor.greyMedium)
            
            ZStack(alignment: .leading) {
                if viewModel.nickname.isEmpty && !isNameFocused {
                    Text("Set your display name")
                        .textStyle(size: 16, color: AppColor.black, fontFamily: .poppinsRegular)
                }
                TextField("", text: $viewModel.nickname)
                    .textStyle(size: 16, color: AppColor.black, fontFamily: .poppinsRegular)
                    .focused($isNameFocused)
                    .tint(AppColor.black)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isNameFocused = true
            }
        }
        .padding(.vertical, 16)
    }
    
    private var saveButton: some View {
        Button {
            Task {
                await viewModel.saveNickname()
                isNameFocused = false
            }
        } label: {
            Text("Save")
                .textStyle(size: 16, color: viewModel.hasChanges ? AppColor.oat : AppColor.greyMedium, fontFamily: .poppinsRegular)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(viewModel.hasChanges ? AppColor.black : AppColor.greyLight)
                )
        }
        .disabled(!viewModel.hasChanges || viewModel.isSaving)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
    
    private var emailSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Email")
                .textStyle(font: .caption, color: AppColor.greyMedium)
            
            Text(viewModel.email.isEmpty ? "—" : viewModel.email)
                .textStyle(size: 16, color: AppColor.black, fontFamily: .poppinsRegular)
        }
        .padding(.vertical, 16)
    }
    
    private var divider: some View {
        Rectangle()
            .fill(AppColor.greyLight)
            .frame(height: 0.5)
    }
}
