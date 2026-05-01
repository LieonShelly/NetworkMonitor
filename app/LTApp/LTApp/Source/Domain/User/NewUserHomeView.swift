//
//  NewUserHomeView.swift
//  LTApp
//

import SwiftUI
import UIComponent

struct NewUserHomeView: View {
    @StateObject var viewModel: NewUserHomeViewModel
    @EnvironmentObject var homeCoordinator: HomeCoordinator
    
    init(viewModel: NewUserHomeViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: .zero) {
            FixedHeader(title: "Self")
            ScrollView(showsIndicators: false) {
                VStack(spacing: 36) {
                    // About me
                    NewUserRow(
                        icon: Image(.userOutlet),
                        title: "About me...",
                        subtitle: viewModel.nickname
                    )
                    .onTapGesture {
                        homeCoordinator.push(UserRoute.aboutMeSetting)
                    }
                    
                    // Talk to me as
                    NewUserRow(
                        icon: Image(.personaOutlet),
                        title: "Talk to me as...",
                        subtitle: "Choose the tone of voice for your insights"
                    )  .onTapGesture {
                        homeCoordinator.push(UserRoute.personaSetting)
                    }
                    
                    
                    // Inspire me with
                    NewUserRow(
                        icon:  Image(.library),
                        title: "Inspire me with...",
                        subtitle: "Browse and pin your favorite sparks"
                    )
                    .onTapGesture {
                        homeCoordinator.push(HomeRoute.questionLib)
                   }
                    
                    // Everyday, ask me
                    NewUserRow(
                        icon: Image(.cardsOutlet),
                        title: "Everyday, ask me...",
                        subtitle: "Set up your daily sparks"
                    )
                    .onTapGesture {
                        homeCoordinator.push(UserRoute.qustionOfTodaySettings)
                    }
                    
                    // Whisper to me at
                    NewUserRow(
                        icon: Image(.reminder),
                        title: "Whisper to me at...",
                        subtitle: "Your daily journal reminder"
                    )
                    .onTapGesture {
                        homeCoordinator.push(UserRoute.reminderSetting)
                    }
                }
                .padding(.top, 16)
            }
            .refreshable {
                try? await viewModel.fetchUserInfo()
            }
        }
        .onFirstAppear {
            Task {
                try? await viewModel.fetchUserInfo()
            }
        }
    }
}
