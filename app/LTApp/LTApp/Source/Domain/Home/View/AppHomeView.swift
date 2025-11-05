//
//  LTApp, This code is protected by intellectual property rights.
//
import SwiftUI
import UIComponent


struct AppHomeView: View {
    @StateObject var viewModel: AppHomeViewModel
    @EnvironmentObject var homeCoordinator: HomeCoordinator
    
    @State var showPage: Bool = false
    
    init(service: any AppDataWithAuthorizationServiceful) {
        self._viewModel = StateObject(wrappedValue: AppHomeViewModel(service: service))
    }
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                if showPage {
                    VStack(spacing: .zero) {
                        AppScrollContentView(viewModel: viewModel.contentViewModel)
                        ZStack(alignment: .bottom) {
                            AppTabbar(viewModel: viewModel.tabbarViewModel)
                                .padding(.horizontal, 50)
                                .padding(.top, 10)
                                
                            TodayQuestionView()
                                .onTapGesture {
                                    homeCoordinator.push(HomeRoute.addTodayAnswer)
                                }
                                .offset(y: -(40 + 16 * 2))
                                .padding(.horizontal, 40)
                                .padding(.bottom, 10)
                        }
                    }
                    .toolbarVisibility(.hidden, for: .navigationBar)
                    .transition(.opacity)
                }
            }
            .frame(width: proxy.size.width)
            .toolbarVisibility(.hidden, for: .navigationBar)
            .defaultBackground()
        }
      
        .task {
            withAnimation(.easeInOut) {
                showPage = true
            }
        }
       
    }
    
    
    var titleView: some View {
        Text("The Little Things")
            .textStyle(size: 36)
            .padding(.top, 35)
    }
}
