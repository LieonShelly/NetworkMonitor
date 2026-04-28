//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI
import UIComponent


struct ThreadView: View {
    @EnvironmentObject var homeCoordinator: HomeCoordinator
    @EnvironmentObject var appCoordinator: AppCoordinator
    @StateObject var viewModel: ThreadViewModel
    @State private var showCategory: Bool = true
    
    let onTapAnswerAction: ((TodayAnswerSubmittedViewModel?) -> Void)?
    let addAnswerAction: (([Question]) -> Void)?
    enum Constants {
        static let iconSize: CGFloat = 24
        static let iconItemSpacing: CGFloat = 8
        static let iconColumns: Int = 7
        static let listHP: CGFloat = 32
        static let pinIconW: CGFloat = 24
        static let quesiontTilteHp: CGFloat = 24
        static let categoryHeight: CGFloat = 88
    }
    
    init(viewModel: ThreadViewModel,
         addAnswerAction: (([Question]) -> Void)?,
         onTapAnswerAction: ((TodayAnswerSubmittedViewModel?) -> Void)?,) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.onTapAnswerAction = onTapAnswerAction
        self.addAnswerAction = addAnswerAction
    }
    
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: .zero) {
                titleView
                ZStack(alignment: .top) {
                    listView(proxy)
                    if showCategory {
                        categoryView()
                            .background(AppColor.backgroundPage)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .zIndex(1)
                    }
                }
            }
            .innerPageRoute($viewModel.subPageRoute)
            .task {
                try? await viewModel.fetchCategories()
                try? await viewModel.fetchDataInCurrentCategory()
            }
        }
    }
    
    func listView(_ proxy: GeometryProxy) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: .zero) {
                if viewModel.questionList.count <= 1 {
                    ForEach(viewModel.questionList, id: \.uid) { question in
                      section(question, paraent: proxy, bottom: 56)
                    }
                    emptyList()
                } else {
                    ForEach(viewModel.questionList, id: \.uid) { question in
                      section(question, paraent: proxy)
                    }
                }
                
                footer
            }
            .padding(.top, 16)
            .padding(.top, viewModel.categories.isEmpty ? 0 : Constants.categoryHeight)
        }
        .padding(.horizontal, Constants.listHP)
        .refreshable {
            try? await viewModel.fetchDataInCurrentCategory()
        }
        .onScrollGeometryChange(for: CGFloat.self) { proxy in
            proxy.contentOffset.y
        } action: { oldValue, newValue in
            let diff = newValue - oldValue
            let threshhold: CGFloat = 5
            withAnimation(.easeInOut) {
                if newValue <= 0 {
                    showCategory = true
                } else if diff > threshhold {
                    showCategory = false
                } else if diff < -threshhold {
                    showCategory = true
                }
            }
        }
    }
    
    func section(_ question: ThreadQuestionItem,
                 paraent: GeometryProxy,
                 bottom: CGFloat = 32) -> some View {
        VStack(alignment: .leading, spacing: .zero) {
            questionRow(question)
            latestAnserView(question: question)
            
            VStack(spacing: .zero) {
                if let didTapShowMore = viewModel.showHandlingMap[question.id] {
                    iconListView(question: question, didTapShowMore: didTapShowMore, proxy: paraent)
                    showMoreOrLessView(question: question, didTapShowMore: didTapShowMore, proxy: paraent)
                } else {
                    iconListView(question: question, proxy: paraent)
                }
            }
            .transition(.scale)
            .padding(.bottom, bottom)
            .padding(.leading, Constants.quesiontTilteHp + Constants.pinIconW)
            .padding(.trailing, Constants.quesiontTilteHp)
            .padding(.top, 12)
            .transition(.opacity.animation(.easeInOut))
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
        let limit = viewModel.limit >= question.otherAnswerItems.count ? question.otherAnswerItems.count : viewModel.limit
        let answerItems = (didTapShowMore ?? true) ? question.otherAnswerItems : Array(question.otherAnswerItems[0 ..< limit])
        LazyVGrid(columns: colums, alignment: .leading, spacing: spacing) {
            ForEach(answerItems) { answer in
                HStack {
                    switch answer.type {
                    case .addBtn:
                        addNewBtn(question)
                    case let .noraml(answer):
                        AnswerIconView(answer: answer,
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
                    .transition(.opacity.animation(.easeInOut))
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
                    .textStyle(font: .caption, color: AppColor.grey)
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
                .textStyle(font: .title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Constants.quesiontTilteHp)
        }
        .transition(.opacity.animation(.easeInOut))
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
                    .padding(.leading, 20)
                    .offset(y: -14)
            }
        }
      
    }
    
    var titleView: some View {
        FixedHeader(title: "Threads") {
            Button {
                homeCoordinator.push(HomeRoute.questionLib)
            } label: {
                Image(.library)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 32, height: 32)
                    .foregroundStyle(AppColor.color(hex: 0x000000))
            }

        }
        .zIndex(10)
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
            .foregroundStyle(AppColor.color(hex: 0x000000))
            .onTapGesture {
                addAnswerAction?([question.toQuestion()])
            }
    }
    
    
    func emptyStateLibSection(title: String,
                              icon: ImageResource,
                              btnTitle: String,
                              ontapAction: (() -> Void)?) -> some View {
        VStack(alignment: .leading, spacing: .zero) {
            Text(title)
                .textStyle(font: .title, color: AppColor.grey)
                .padding(.horizontal, Constants.quesiontTilteHp + Constants.pinIconW)
            
            Button {
                ontapAction?()
            } label: {
                HStack(spacing: .zero) {
                    Image(icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                        .foregroundStyle(AppColor.color(hex: 0xffffff))
                    
                    Text(btnTitle)
                        .textStyle(font: .section, color: AppColor.white)
                        .padding(.leading, 6)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 16)
                .background {
                    Capsule()
                        .fill(AppColor.greyDark)
                }
            }
            .padding(.bottom, 56)
            .padding(.leading, Constants.quesiontTilteHp + Constants.pinIconW)
            .padding(.trailing, Constants.quesiontTilteHp)
            .padding(.top, 8)
        }
        .overlay(alignment: .leading) {
            line()
        }
    }
    
    @ViewBuilder
    func emptyList() -> some View {
        emptyStateLibSection(title: "Pin your fav spark here to easily find it again", icon: .library, btnTitle: "Browse the Spark Library ") {
            homeCoordinator.push(HomeRoute.questionLib)
        }
        emptyStateLibSection(title: "Capture a moment to start stringing your thread", icon: .threadAdd, btnTitle: "Explore Today's Spark") {
            addAnswerAction?([])
        }
    }
    
    @ViewBuilder
    func latestAnserView(question: ThreadQuestionItem) -> some View {
        if let answerItem = question.latestAnswerItem, let answer = answerItem.answer {
            HStack(alignment: .top, spacing: .zero) {
                AnswerIconView(answer: answer,
                         size: .init(width: Constants.iconSize, height: Constants.iconSize))
                    .onTapGesture {
                        let question = question.toQuestion()
                        onTapAnswerAction?(.init(answer: answer, question: .init(id: question.id, title: question.title), service: viewModel.service))
                    }
                
                Text(answer.content)
                    .multilineTextAlignment(.leading)
                    .textStyle(font: .body, color: AppColor.greyMedium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Constants.quesiontTilteHp)
            }
            .padding(.top, 8)
            .transition(.opacity.animation(.easeInOut))
        }
    }
    
    @ViewBuilder func categoryView() -> some View {
        if !viewModel.categories.isEmpty {
            ThreadCategoryView(
                items: viewModel.categories,
                selectedIndex: viewModel.selectedCategoryIndex,
                onTap: { index in
                    Task {
                        await viewModel.selecteCategory(index)
                    }
                })
            .frame(height: 58)
            .padding(.horizontal, Constants.listHP)
            .transition(.opacity.animation(.easeInOut))
            .frame(height: Constants.categoryHeight)
        }
    }
}

