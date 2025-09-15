//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

struct OnboardingView: View {
    enum PageState {
        case onboarding
        case welcome
    }
    let topics: [String] = ["Daily life", "Career growth", "Relationship"]
   @State var selectedTopic: String? = nil
    @EnvironmentObject var coordinator: AppCoordinator
    @State var currentPage: PageState = .onboarding
    
    var body: some View {
        VStack(spacing: .zero) {
            switch currentPage {
            case .onboarding:
                onboardingContent
            case .welcome:
                coordinator.build(AppRoute.welcome)
            }
        }
        .defaultBackground()
        .toolbarVisibility(.hidden, for: .navigationBar)
        
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
            ForEach(topics, id: \.self) { topic in
                DashLineButton(text: topic, isSelected: selectedTopic == topic) {
                    selectedTopic = topic
                }
                .frame(height: 112)
            }
        }
        .padding(.horizontal, 32)
        .padding(.top, 61)
       
    }
    
    var bottomBtn: some View {
        DefaultAppButton(
            isEnabled: selectedTopic != nil,
            title: "Next") {
                withAnimation(.easeInOut(duration: 0.25)) {
                    currentPage = .welcome
                }
            }
        .padding(.horizontal, 32)
    }
}


#Preview {
    OnboardingView()
}
