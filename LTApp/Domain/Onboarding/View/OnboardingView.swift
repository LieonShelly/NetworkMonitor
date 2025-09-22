//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

struct OnboardingView: View {
    enum PageState {
        case onboarding
        case welcome
    }
    
    @State var selectedCategory: Category? = nil
    @EnvironmentObject var coordinator: PreHomeCoordinator
    @State var currentPage: PageState = .onboarding
    @ObservedObject var viewModel: OnboardingViewModel
    
    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: .zero) {
            switch currentPage {
            case .onboarding:
                onboardingContent
            case .welcome:
                if let selectedCategory {
                    coordinator.build(PreHomeRoute.welcome(selectedCategory))
                }
            }
        }
        .defaultBackground()
        .toolbarVisibility(.hidden, for: .navigationBar)
        .task {
            await viewModel.fetchData()
        }
    }
    
    var onboardingContent: some View {
        VStack(spacing: .zero) {
            title
            topicList
            Spacer()
            bottomBtn
        }
        .transition(.asymmetric(insertion: .identity, removal: .opacity))
    }
    
    var title: some View {
        HStack {
            Text("Which aspect do you want to focus on?")
                .multilineTextAlignment(.leading)
                .font(AppFont.feltTipSenior(size: 36))
                .foregroundStyle(AppColor.textPrimary)
            Spacer()
        }
        .padding(.top, 70)
        .padding(.horizontal, 32)
    }
    
    var topicList: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.list, id: \.id) { category in
                DashLineButton(
                    text: category.name ,
                    isSelected: selectedCategory == category) {
                    selectedCategory = category
                }
                .frame(height: 112)
            }
        }
        .padding(.horizontal, 32)
        .padding(.top, 61)
        
    }
    
    var bottomBtn: some View {
        DefaultAppButton(
            isEnabled: selectedCategory != nil,
            title: "Next") {
                withAnimation(.easeInOut(duration: 0.25)) {
                    currentPage = .welcome
                }
            }
            .padding(.horizontal, 32)
    }
}

