//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI
import UIComponent


struct ReflectionDetailView: View {
    @StateObject var viewModel: ReflectionDetailViewModel
    @EnvironmentObject var homeCoordinator: HomeCoordinator
    @State var showSummary: Bool = false
    @State var showDelete: Bool = false
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
                deleteView
            }
            .toolbarVisibility(.hidden, for: .navigationBar)
            .animation(.easeInOut, value: showSummary)
            .animation(.easeInOut, value: showDelete)
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
    
    @ViewBuilder var deleteView: some View {
        if showDelete {
            DeleteAnswerView(isPresented: $showDelete) {
                Task {
                   try? await viewModel.deleteAnswer()
                }
            }
                .transition(.opacity)
                .zIndex(4)
        }
    }
    
    var addBtn: some View {
        AddBtnView(
            addAction: {
                viewModel.route(.addSingleAnswer(viewModel.generateTodayViewModel([viewModel.question])))
            },
            addIconsize: .init(width: 18, height: 18),
            blurBgSize: .init(width: 48, height: 48)
        )
        .padding(.trailing, 30)
        .padding(.bottom, 30)
    }
    
    func contentView(_ proxy: GeometryProxy) -> some View {
        ScrollView {
            LazyVStack(spacing: .zero) {
                topbar(proxy).opacity(0) // for placeholder
                totalView
                LazyVStack(spacing: .zero) {
                    ForEach(viewModel.answers, id: \.uid) { answer in
                        DetailAnswerRow(answer: answer)
                            .contentShape(.rect)
                            .transition(.opacity.animation(.easeInOut))
                            .onTapGesture {
                                viewModel.route(.answerDetail(.init(answer: answer, question: viewModel.question, service: viewModel.service)))
                            }
                           
                            .onLongPressGesture(minimumDuration: 0.5) {
                                showDelete = true
                                viewModel.longPressAnswer = answer
                            }
                    }
                }
                .padding(.horizontal, 32)
            }
        }
        .defaultBackground()
        .zIndex(1)
        .refreshable(action: {
            try? await viewModel.fetchData()
        })
        .overlay(alignment: .bottomTrailing) {
            addBtn
        }
    }
    
    @ViewBuilder var totalView: some View {
        if let sumary = viewModel.sumary {
            Button {
                showSummary.toggle()
            } label: {
                Text("\(sumary.totalAnswers) answers, \(sumary.daysOver) days ")
                    .textStyle(font: .caption, color: AppColor.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background {
                        Capsule()
                            .fill(AppColor.color(hex: 0x000000))
                    }
            }
            .padding(.bottom, 20)
            
        }
    }
    
    func topbar(_ proxy: GeometryProxy) -> some View {
        VStack(spacing: .zero) {
            FixedHeader(title: viewModel.title, size: .large, backAction: {
                homeCoordinator.pop()
            })
            
            LinearGradient(gradient: .init(colors: [
                AppColor.color(hex: 0xFFFDF8).opacity(0),
                AppColor.color(hex: 0xFFFDF8),
            ]), startPoint: .init(x: 0.5, y: 1), endPoint: .init(x: 0.5, y: 0))
            .frame(height: 20)
        }
        .zIndex(2)
    }
}

