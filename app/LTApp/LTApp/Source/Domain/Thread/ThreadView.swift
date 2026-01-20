//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI
import UIComponent


struct ThreadView: View {
    @EnvironmentObject var homeCoordinator: HomeCoordinator
    @EnvironmentObject var appCoordinator: AppCoordinator
    @StateObject var viewModel: ThreadViewModel
    let onTapAnswerAction: ((TodayAnswerSubmittedViewModel?) -> Void)?
    let addAnswerAction: ((Question?) -> Void)?
    enum Constants {
        static let iconSize: CGFloat = 24
        static let iconItemSpacing: CGFloat = 8
        static let iconColumns: Int = 7
        static let listHP: CGFloat = 24
        static let pinIconW: CGFloat = 24
        static let quesiontTilteHp: CGFloat = 24
    }
    init(viewModel: ThreadViewModel,
         addAnswerAction: ((Question?) -> Void)?,
         onTapAnswerAction: ((TodayAnswerSubmittedViewModel?) -> Void)?,) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.onTapAnswerAction = onTapAnswerAction
        self.addAnswerAction = addAnswerAction
    }
    
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: .zero) {
                titleView
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: .zero) {
                        ForEach(viewModel.questionList, id: \.id) { question in
                          section(question, paraent: proxy)
                        }
                        if !viewModel.questionList.isEmpty {
                            footer
                        }
                    }
                    .padding(.top, 16)
                }
                .padding(.horizontal, Constants.listHP)
                .refreshable {
                    do {
                        try await viewModel.fetchData()
                    } catch {
                        print("threadView:\(error)")
                    }
                }
            }
            .innerPageRoute($viewModel.subPageRoute)
            .task {
                do {
                    try await viewModel.fetchData()
                } catch {
                    print("threadView:\(error)")
                }
            }
        }
    }
    
    func section(_ question: ThreadQuestionItem, paraent: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: .zero) {
            questionRow(question)
            VStack(spacing: .zero) {
                if let didTapShowMore = viewModel.showHandlingMap[question.id] {
                    iconListView(question: question, didTapShowMore: didTapShowMore, proxy: paraent)
                    showMoreOrLessView(question: question, didTapShowMore: didTapShowMore, proxy: paraent)
                } else {
                    iconListView(question: question, proxy: paraent)
                }
            }
            .transition(.scale)
            .padding(.bottom, 32)
            .padding(.leading, Constants.quesiontTilteHp + Constants.pinIconW)
            .padding(.trailing, Constants.quesiontTilteHp)
            .padding(.top, 8)
        }
        .overlay(alignment: .leading) {
            line()
        }
    }
    
    @ViewBuilder
    func iconListView(question: ThreadQuestionItem, didTapShowMore: Bool? = nil,  proxy: GeometryProxy) -> some View {
        let columnCount: Int = Constants.iconColumns
        let spacing: CGFloat = Constants.iconItemSpacing
        let iconListW = proxy.size.width - Constants.listHP * 2 - Constants.pinIconW - Constants.quesiontTilteHp * 2
        let itemWidth: CGFloat = (iconListW - (spacing * CGFloat(columnCount - 1))) / CGFloat(columnCount)
        let colums = (0 ..< columnCount).map { _ in GridItem(.fixed(itemWidth), spacing: spacing) }
        let limit = viewModel.limit >= question.answerItems.count ? question.answerItems.count : viewModel.limit
        let answerItems = (didTapShowMore ?? true) ? question.answerItems : Array(question.answerItems[0 ..< limit])
        LazyVGrid(columns: colums, alignment: .leading, spacing: spacing) {
            ForEach(answerItems) { answer in
                HStack {
                    switch answer.type {
                    case .addBtn:
                        addNewBtn(question)
                    case let .noraml(answer):
                        IconView(answer: answer,
                                 size: .init(width: Constants.iconSize, height: Constants.iconSize))
                            .onTapGesture {
                                onTapAnswerAction?(.init(answer: answer, question: .init(id: question.id, title: question.title), service: viewModel.service))
                            }
                    case .placeholder:
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: Constants.iconSize, height: Constants.iconSize)
                    }
                }.frame(width: itemWidth, height: itemWidth)
            }
        }
    }
    
    @ViewBuilder
    func showMoreOrLessView(question: ThreadQuestionItem, didTapShowMore: Bool, proxy: GeometryProxy) -> some View {
        let columnCount: Int = Constants.iconColumns
        let spacing: CGFloat = Constants.iconItemSpacing
        let iconListW = proxy.size.width - Constants.listHP * 2 - Constants.pinIconW - Constants.quesiontTilteHp * 2
        let itemWidth: CGFloat = (iconListW - (spacing * CGFloat(columnCount - 1))) / CGFloat(columnCount)
        if question.hasExactDivided {
            specialShowLessView(question: question, didTapShowMore: didTapShowMore, proxy: proxy)
        } else {
            HStack(spacing: Constants.iconItemSpacing, content: {
                ForEach( 1 ... Constants.iconColumns, id: \.self) { index in
                    HStack {
                        if index == Constants.iconColumns {
                            addNewBtn(question)
                        } else {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: Constants.iconSize, height: Constants.iconSize)
                        }
                    }
                    .frame(width: itemWidth, height: itemWidth)
                }
                .opacity(didTapShowMore ? 0 : 1)
            })
            .overlay(alignment: .leading, content: {
                Text(didTapShowMore ? "show less" : "show more")
                    .textStyle(size: 10, color: AppColor.color(hex: 0xBFBFBF), fontFamily: .poppinsRegular)
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            viewModel.didTapShowMore(question)
                        }
                    }
            })
            .padding(.top, 8)
        }
     
    }
    
    
    @ViewBuilder
    func specialShowLessView(question: ThreadQuestionItem, didTapShowMore: Bool, proxy: GeometryProxy) -> some View {
        let columnCount: Int = Constants.iconColumns
        let spacing: CGFloat = Constants.iconItemSpacing
        let iconListW = proxy.size.width - Constants.listHP * 2 - Constants.pinIconW - Constants.quesiontTilteHp * 2
        let itemWidth: CGFloat = (iconListW - (spacing * CGFloat(columnCount - 1))) / CGFloat(columnCount)
        HStack(spacing: Constants.iconItemSpacing, content: {
            ForEach( 1 ... Constants.iconColumns, id: \.self) { index in
                HStack {
                    if index == Constants.iconColumns {
                        addNewBtn(question)
                    } else {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: Constants.iconSize, height: Constants.iconSize)
                    }
                }
                .frame(width: itemWidth, height: itemWidth)
            }
        })
        .overlay(alignment: .leading, content: {
            Text(didTapShowMore ? "show less" : "show more")
                .textStyle(size: 10, color: AppColor.color(hex: 0xBFBFBF), fontFamily: .poppinsRegular)
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        viewModel.didTapShowMore(question)
                    }
                }
        })
        .padding(.top, 8)
    }
          
    func questionRow(_ question: ThreadQuestionItem) -> some View {
        HStack(alignment: .top, spacing: .zero) {
            
            Image(.pinnedStar)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Constants.pinIconW, height: Constants.pinIconW)
                .padding(.top, 4)
                .opacity(question.pinned ? 1 : 0)
            
            Text(question.title)
                .lineLimit(5)
                .multilineTextAlignment(.leading)
                .textStyle(size: 24, fontFamily: .feltTipSeniorRegular)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Constants.quesiontTilteHp)
        }
        .onTapGesture {
            homeCoordinator.push(
                HomeRoute.reflectionDetail(
                    questionId: question.id,
                    title: question.title
                )
            )
        }
    
    }
    
    func line(_ showball: Bool = false, segmentCount: Int = 40, seed: Int = 100) -> some View {
        VStack(alignment: .leading, spacing: .zero) {
            WavyLine(segmentCount: segmentCount, seed: seed)
                .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .foregroundColor(AppColor.color(hex: 0x000000))
                .frame(width: 2)
                .padding(.leading, 32)
            if showball {
                Image(.union)
                    .padding(.leading, 30)
                    .offset(y: -14)
            }
        }
      
    }
    
    var titleView: some View {
        ZStack(alignment: .trailing) {
            Button {
                homeCoordinator.push(HomeRoute.questionLib)
            } label: {
                Image(.library)
                    .resizable()
                    .frame(width: 32, height: 32)
            }
            HStack(spacing: .zero) {
                Spacer()
                Text("Threads")
                    .textStyle(size: 32, fontFamily: .feltTipSeniorRegular)
                Spacer()

            }
        }
        .padding(.horizontal, 24)
    }
    
    var footer: some View {
        Rectangle()
            .fill(Color.clear)
            .frame(height: 80)
            .overlay(alignment: .leading) {
                line(true, segmentCount: 10, seed: 40)
            }
            .padding(.bottom, 200)
    }
    
    func addNewBtn(_ question: ThreadQuestionItem) -> some View {
        Image(.threadAdd)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: Constants.iconSize, height: Constants.iconSize)
            .onTapGesture {
                addAnswerAction?(question.toQuestion())
            }
    }
}
