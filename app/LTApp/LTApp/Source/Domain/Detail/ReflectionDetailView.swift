//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI
import UIComponent


struct ReflectionDetailView: View {
    @StateObject var viewModel: ReflectionDetailViewModel
    @EnvironmentObject var homeCoordinator: HomeCoordinator
    @State var showSummary: Bool = false
    @State var navibarOpacity: CGFloat = 0
    @State var subPagePrensented: Bool = false
    
    enum Constants {
        static let navibarH: CGFloat = 85
        static let backBtnSize: CGFloat = 32
        static let navibarTop: CGFloat = 20
    }
    
    init(viewModel: ReflectionDetailViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                topbar(proxy)
                contentView(proxy)
                summaryView
            }
            .toolbarVisibility(.hidden, for: .navigationBar)
            .animation(.easeInOut, value: showSummary)
            .innerPageRoute($viewModel.subPageRoute)
        }
        .task {
            do {
                try await viewModel.fetchData()
            } catch {
                print("ReflectionDetailView-error: \(error)")
            }
        }
    }
    
   @ViewBuilder var summaryView: some View {
        
        if showSummary, let sumary = viewModel.sumary {
            SummaryView(summary: sumary, isPresented: $showSummary)
                .transition(.opacity)
                .zIndex(3)
        }
    }
    
    func contentView(_ proxy: GeometryProxy) -> some View {
        ScrollView {
            LazyVStack(spacing: .zero) {
                topbar(proxy).opacity(0) // for placeholder
                totalView
                LazyVStack(spacing: .zero) {
                    ForEach(viewModel.answers, id: \.id) { answer in
                        DetailAnswerRow(answer: answer)
                            .onTapGesture {
                                viewModel.route(.answerDetail(.init(answer: answer, question: viewModel.question, service: viewModel.service)))
                            }
                    }
                }
                .padding(.horizontal, 32)
            }
        }
        .defaultBackground()
        .zIndex(1)
    }
    
    @ViewBuilder var totalView: some View {
        if let sumary = viewModel.sumary {
            Button {
                showSummary.toggle()
            } label: {
                Text("\(sumary.totalAnswers) answers, \(sumary.daysOver) days ")
                    .textStyle(size: 10, color: AppColor.color(hex: 0xffffff), fontFamily: .poppinsRegular)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppColor.color(hex: 0x000000))
                    }
            }
            .padding(.bottom, 20)
            
        }
    }
    
    func topbar(_ proxy: GeometryProxy) -> some View {
        VStack(spacing: .zero) {
            HStack(alignment: .top, spacing: .zero) {
                Button {
                    homeCoordinator.pop()
                } label: {
                    Image(.back)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Constants.backBtnSize, height: Constants.backBtnSize)
                        .padding(.leading, 25)
                }
                Text(viewModel.title)
                    .lineLimit(5)
                    .textStyle(size: 32, fontFamily: .feltTipSeniorRegular)
                    .padding(.leading, 12)
                    .padding(.trailing, 24)
                
                Spacer()
            }
            .padding(.top, 20)
            .background(AppColor.backgroundPage)
            
            LinearGradient(gradient: .init(colors: [
                AppColor.color(hex: 0xFFFDF8).opacity(0),
                AppColor.color(hex: 0xFFFDF8),
            ]), startPoint: .init(x: 0.5, y: 1), endPoint: .init(x: 0.5, y: 0))
            .frame(height: 20)
        }
      
         .zIndex(2)
    }
}

