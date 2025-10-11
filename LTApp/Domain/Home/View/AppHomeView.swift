//
//  LTApp, This code is protected by intellectual property rights.
//
import SwiftUI

struct AppHomeView: View {
    @ObservedObject var viewModel: AppHomeViewModel
    
    @State var showPage: Bool = false
    
    var body: some View {
        VStack {
            if showPage {
                VStack(spacing: .zero) {
                    AppScrollContentView(viewModel: viewModel.contentViewModel)
                    
                    AppTabbar(viewModel: viewModel.tabbarViewModel)
                        .padding(.horizontal, 50)
                        .padding(.top, 10)
                }
                .toolbarVisibility(.hidden, for: .navigationBar)
                .transition(.opacity)
            }
        }
        .toolbarVisibility(.hidden, for: .navigationBar)
        .defaultBackground()
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
