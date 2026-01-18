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
    }
    init(viewModel: ThreadViewModel,
         addAnswerAction: ((Question?) -> Void)?,
         onTapAnswerAction: ((TodayAnswerSubmittedViewModel?) -> Void)?,) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.onTapAnswerAction = onTapAnswerAction
        self.addAnswerAction = addAnswerAction
    }
    
    var body: some View {
        VStack(spacing: .zero) {
            titleView
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: .zero) {
                    listContent
                    if !viewModel.questionList.isEmpty {
                        footer
                    }
                }
                .padding(.top, 16)
            }
            .padding(.horizontal, 24)
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
    
    @ViewBuilder
    var listContent: some View {
        ForEach(viewModel.questionList, id: \.id) { question in
          section(question)
        }
    }
    
    func section(_ question: ThreadQuestionItem) -> some View {
        VStack(alignment: .leading, spacing: .zero) {
            questionRow(question)
                .background(Color.random)
            VStack(spacing: .zero) {
                if let didTapShowMore = viewModel.showHandlingMap[question.id] {
                    iconListView(question: question, didTapShowMore: didTapShowMore)
                    showMoreOrLessView(question: question, didTapShowMore: didTapShowMore)
                } else {
                    iconListView(question: question)
                }
            }
            .transition(.scale)
            .padding(.bottom, 32)
            .padding(.leading, 24 + 24)
            .padding(.trailing, 24)
            .padding(.top, 8)
        }
        .overlay(alignment: .leading) {
            line()
        }
    }
    
    @ViewBuilder
    func iconListView(question: ThreadQuestionItem, didTapShowMore: Bool? = nil) -> some View {
        let columnCount: Int = 7
        let colums = (0 ..< columnCount).map { _ in GridItem(.fixed(Constants.iconSize), spacing: 8) }
        let answerItems = (didTapShowMore ?? true) ? question.answerItems : Array(question.answerItems[0 ..< viewModel.limit])
        LazyVGrid(columns: colums, spacing: 8) {
            ForEach(answerItems) { answer in
                
                switch answer.type {
                case .addBtn:
                    addNewBtn(question)
                case let .noraml(answer):
                    IconView(answer: answer, size: .init(width: Constants.iconSize, height: Constants.iconSize))
                        .onTapGesture {
                            onTapAnswerAction?(.init(answer: answer, question: .init(id: question.id, title: question.title), service: viewModel.service))
                        }
                case .placeholder:
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: Constants.iconSize, height: Constants.iconSize)
                }
            }
        }
        .background(Color.random)
    }
    
    @ViewBuilder
    func showMoreOrLessView(question: ThreadQuestionItem, didTapShowMore: Bool) -> some View {
        if question.hasExactDivided {
            specialShowLessView(question: question, didTapShowMore: didTapShowMore)
        } else {
            HStack(spacing: 8, content: {
                ForEach( 1 ... 7, id: \.self) { index in
                    if index == 7 {
                        addNewBtn(question)
                    } else {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: Constants.iconSize, height: Constants.iconSize)
                    }
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
    
    
    func specialShowLessView(question: ThreadQuestionItem, didTapShowMore: Bool) -> some View {
        HStack(spacing: 8, content: {
            ForEach( 1 ... 7, id: \.self) { index in
                if index == 7 {
                    addNewBtn(question)
                } else {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: Constants.iconSize, height: Constants.iconSize)
                }
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
                .frame(width: 24, height: 24)
                .padding(.top, 4)
            
            Text(question.title)
                .lineLimit(5)
                .textStyle(size: 24, fontFamily: .feltTipSeniorRegular)
                .background(Color.random)
                .padding(.horizontal, 24)
               
            Spacer()
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
