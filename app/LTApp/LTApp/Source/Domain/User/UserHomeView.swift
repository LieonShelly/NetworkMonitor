//
//  UserHomeView.swift
//  LTApp
//
//  Created by Renjun Li on 2025/10/30.
//


import SwiftUI

struct UserHomeView: View {
    @StateObject var viewModel: UserHomeViewModel
    @EnvironmentObject var homeCoordinator: HomeCoordinator
    
    var body: some View {
        VStack(spacing: .zero) {
            titleView
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 40) {
                    UserRow(item: .init(icon: Image(.userOutlet), title: "Name", subTitle: viewModel.userName))
                    
                    UserRow(item: .init(icon: Image(.libraryOutlet), title: "Question Library", subTitle: "Pin your favourite questions to the threads"))
                        .onTapGesture {
                            homeCoordinator.push(HomeRoute.questionLib)
                        }
                    
                    UserRow(item: .init(icon: Image(.libraryOutlet), title: "Question of the Day", subTitle: "Manage your preferred questions"))
                        .onTapGesture {
                            homeCoordinator.push(UserRoute.qustionOfTodaySettings)
                        }
                    
                    UserRow(item: .init(icon: Image(.reminder), title: "Reminder", subTitle: "Personalizaed to your own rhythm"))
                }
                .padding(.top, 26)
            }
        }
        .onFirstAppear {
            Task {
                try? await viewModel.featchData()
            }
        }
    }
    
    var titleView: some View {
        HStack(spacing: .zero) {
            Text("Self")
                .textStyle(size: 32)
        }
        .padding(.leading, 24)
    }
    
}

