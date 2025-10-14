//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

struct ReflectionDetailView: View {
    @StateObject var viewModel: ReflectionDetailViewModel
    @EnvironmentObject var homeCoordinator: HomeCoordinator
    @State var isPresentedDetail: Bool = false
    @State var isPresentDetail: Bool = false
    @State var showSummary: Bool = false
    
    init(viewModel: ReflectionDetailViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: .zero) {
                titleView
                totalView
                LazyVStack(spacing: .zero) {
                    ForEach(viewModel.answers, id: \.id) { answer in
                        DetailAnswerRow(answer: answer)
                    }
                }
                .padding(.horizontal, 32)
            }
        }
        .defaultBackground()
        .defaultNavigationBar("") {
            homeCoordinator.pop()
        }
        .fullScreenCover(isPresented: $isPresentedDetail, content: {
            ZStack(alignment: .bottom) {
                if showSummary, let sumary = viewModel.sumary {
                    AppColor.color(hex: 0x000000).opacity(0.25)
                        .transition(.opacity)
                        .onTapGesture {
                            isPresentDetail.toggle()
                        }
                    
                    SummaryView(summary: sumary)
                        .background(FullScreenCoverBackgroundRemovalView())
                        .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))
                        .zIndex(100)
                        .onDisappear {
                            isPresentedDetail = false
                        }
                        
                }
            }
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut) {
                    showSummary = true
                }
            }
          
        })
        .onChange(of: isPresentDetail, { oldValue, newValue in
            if newValue {
                isPresentedDetail = true
            } else {
                withAnimation(.easeInOut) {
                    showSummary = false
                }
            }
        })
        .transaction { transaction in
            transaction.disablesAnimations = true
        }
        
        .task {
            do {
                try await viewModel.fetchData()
            } catch {
                
            }
        }
     
    }
    
    var titleView: some View {
        Text(viewModel.title)
            .textStyle(size: 32)
            .padding(.horizontal, 42)
            .padding(.top, 10)
    }
    
    @ViewBuilder var totalView: some View {
        if let sumary = viewModel.sumary {
            Button {
                isPresentDetail.toggle()
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
}



public struct FullScreenCoverBackgroundRemovalView: UIViewRepresentable {
    private class BackgroundRemovalView: UIView {
        override func didMoveToWindow() {
            super.didMoveToWindow()
            superview?.superview?.backgroundColor = .clear
        }
    }
    
    public init() {}
    
    public func makeUIView(context: Context) -> UIView {
        return BackgroundRemovalView()
    }
    
    public func updateUIView(_ uiView: UIView, context: Context) {}
}
