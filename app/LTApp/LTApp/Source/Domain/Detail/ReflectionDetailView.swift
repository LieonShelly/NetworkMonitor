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
            .ignoresSafeArea(edges: .top)
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
                titleView
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
        .contentMargins(.top, .init(top: proxy.safeAreaInsets.top + Constants.navibarH, leading: 0, bottom: 0, trailing: 0), for: .scrollContent)
        .onScrollGeometryChange(for: CGFloat.self, of: { $0.contentOffset.y }, action: { oldValue, newValue in
            if newValue < 0 {
                navibarOpacity = 1 - abs(newValue) / (proxy.safeAreaInsets.top + Constants.navibarH)
            } else {
                withAnimation(.easeInOut) {
                    navibarOpacity = 1
                }
            }
            
        })
        .defaultBackground()
        .zIndex(1)
    }
    
    var titleView: some View {
        Text(viewModel.title)
            .textStyle(size: 32)
            .padding(.horizontal, 42)
            .padding(.top, 10)
            .opacity(1 - navibarOpacity)
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
            .padding(.top, 27)
            .padding(.bottom, 24)
            
        }
    }
    
    func topbar(_ proxy: GeometryProxy) -> some View {
        
         VStack(spacing: .zero) {
             AppColor.backgroundPage
                 .frame(height: proxy.safeAreaInsets.top)
             
             HStack(spacing: .zero) {
                 Button {
                     homeCoordinator.pop()
                 } label: {
                     Image(.back)
                         .padding(.leading, 25)
                 }
                 Text(viewModel.title)
                     .lineLimit(2)
                     .textStyle(size: 24, fontFamily: .feltTipSeniorRegular)
                     .padding(.vertical, 14)
                     .padding(.leading, 15)
                     .padding(.trailing, 24)
                     .opacity(navibarOpacity)
                 
                 Spacer()
             }
             
             Rectangle()
                 .fill(AppColor.color(hex: 0xCDCDCD))
                 .frame(height: 1)
                 .opacity(navibarOpacity)
         }
         .background(AppColor.backgroundPage.opacity(navibarOpacity))
         .frame(height: Constants.navibarH + proxy.safeAreaInsets.top)
         .zIndex(2)
        
        
    }
}

