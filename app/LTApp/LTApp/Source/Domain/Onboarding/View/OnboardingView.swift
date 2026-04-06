//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI
import UIComponent

struct OnboardingView: View {
    enum PageState {
        case onboarding
        case welcome
    }
    
    @State var selectedCategory: Category? = nil
    @EnvironmentObject var coordinator: PreHomeCoordinator
    @State var currentPage: PageState = .onboarding
    @StateObject var viewModel: OnboardingViewModel
    
    init(viewModel: OnboardingViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: .zero) {
            switch currentPage {
            case .onboarding:
                onboardingContent
            case .welcome:
                if let selectedCategory,
                let welcomeView = coordinator.build(PreHomeRoute.welcome(selectedCategory)) {
                    welcomeView
                        .onDisappear {
                            self.currentPage = .onboarding
                        }
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
            bottomBtn
        }
        .transition(.asymmetric(insertion: .identity, removal: .opacity))
    }
    
    var title: some View {
        HStack {
            Text("Pick a focus area you want to start with")
                .multilineTextAlignment(.leading)
                .textStyle(font: .heading)
            Spacer()
        }
        .padding(.top, 70)
        .padding(.horizontal, 32)
    }
    
    @State var visibleButtonIndices: Set<Int> = []
    @State var showBottomBtn: Bool = false
    
    var topicList: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(0 ..< viewModel.list.count, id: \.self) { index in
                        let category = viewModel.list[index]
                        buttton(
                            category: category,
                            selected: selectedCategory == category,
                            index: index
                        )
                        .offset(y: visibleButtonIndices.contains(index) ? 0 : 200)
                        .opacity(visibleButtonIndices.contains(index) ? 1 : 0)
                        .animation(
                            .easeOut(duration: 0.4).delay(Double(index) * 0.1),
                            value: visibleButtonIndices.contains(index)
                        )
                    }
                }
            }
            .frame(height: 110 * 4)
            .padding(.horizontal, 27)
            .clipped()
        }
        .frame(maxHeight: .infinity)
        .onChange(of: viewModel.list) { _, newList in
            guard !newList.isEmpty else { return }
            revealButtons(count: newList.count)
        }
        .onAppear {
            if !viewModel.list.isEmpty {
                revealButtons(count: viewModel.list.count)
            }
        }
    }
    
    private func revealButtons(count: Int) {
        guard visibleButtonIndices.isEmpty else { return }
        withAnimation(.easeIn(duration: 0.4)) {
            for i in 0..<count {
                visibleButtonIndices.insert(i)
            }
        }
        let totalDelay = Double(count) * 0.1 + 0.4
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDelay) {
            withAnimation(.easeOut(duration: 0.4)) {
                showBottomBtn = true
            }
        }
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
            .offset(y: showBottomBtn ? 0 : 100)
            .opacity(showBottomBtn ? 1 : 0)
    }
    
    @ViewBuilder
    func buttton(category: Category, selected: Bool, index: Int) -> some View {
        let degree: CGFloat =  CGFloat(index).truncatingRemainder(dividingBy: 2) == 0 ? -2 : 2
        Button {
            selectedCategory = category
        } label: {
            HStack {
                HStack(spacing: .zero) {
                    SVGImageView(url: category.imageUrl, renderMode: .template)
                        .foregroundStyle(selected ? AppColor.white: AppColor.black)
                        .frame(width: 32, height: 32)
                    Text(category.name)
                        .textStyle(font: .title, color: selected ? AppColor.white : AppColor.black)
                        .padding(.leading, 12)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 80)
                .background {
                    if selected {
                        Capsule().fill(AppColor.black)
                    } else {
                        Image(.wvBtnBg)
                            .resizable()
                    }
                }
                .rotationEffect(.degrees(degree))
            }
            .padding(.horizontal, 5)
            .frame(height: 110)
        }
    }
}

