//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI
import UIComponent


struct ThreadView: View {
    @EnvironmentObject var homeCoordinator: HomeCoordinator
    @EnvironmentObject var appCoordinator: AppCoordinator
    @StateObject var viewModel: ThreadViewModel
    
    init(viewModel: ThreadViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
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
                .padding(.top, 60)
            }
            .padding(.leading, 40)
            .padding(.trailing, 20)
        }
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
    
    func section(_ question: ThreadQuestion) -> some View {
        VStack(alignment: .leading, spacing: .zero) {
            questionRow(question.title)
            VStack(alignment: .leading, spacing: .zero) {
                ForEach(0 ..< 3) { index in
                    if index < question.answers.count {
                        let answer = question.answers[index]
                        answerRow(answer)
                    }
                }
                if question.answers.count >= 3 {
                    moreBtn
                } else {
                    addNewBtn(answerCount: question.answers.count, question: question)
                }
            }
            .padding(.top, 10)
        }
        .overlay(alignment: .leading) {
            line()
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
    
    
    func answerRow(_ answer: Answer) -> some View {
        HStack(spacing: .zero) {
            Rectangle()
                .fill(Color.clear)
                .frame(width: 30, height: 30)
                .overlay {
                    if let url = answer.icon?.url {
                        ThumbnailIconImageView(url: url) {
                            Image(.calendarDripper)
                        }
                        .frame(width: 24, height: 24)
                    } else {
                        Circle()
                            .fill(AppColor.color(hex: 0x848484))
                            .frame(width: 4, height: 4)
                    }
                }
                .padding(.trailing, 24)
               
            Text(answer.content)
                .lineLimit(1)
                .textStyle(size: 12, color: AppColor.color(hex: 0x6f6f6f), fontFamily: .poppinsRegular)
            Spacer()
        }
    }
    
    func questionRow(_ value: String) -> some View {
        HStack {
            Text(value)
                .lineLimit(5)
                .textStyle(size: 20)
            Spacer()
        }
        .padding(.leading, 51)
    }
    
    func line(_ showball: Bool = false, segmentCount: Int = 40, seed: Int = 100) -> some View {
        VStack(alignment: .leading, spacing: .zero) {
            WavyLine(segmentCount: segmentCount, seed: seed)
                .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .foregroundColor(AppColor.color(hex: 0x000000))
                .frame(width: 2)
                .padding(.leading, 40)
            if showball {
                Image(.union)
                    .padding(.leading, 30)
                    .offset(y: -14)
            }
        }
      
    }
    
    var titleView: some View {
        ZStack(alignment: .leading) {
            Button {
                homeCoordinator.push(HomeRoute.questionLib)
            } label: {
                Image(.menu)
                    .resizable()
                    .frame(width: 32, height: 32)
            }
            HStack(spacing: .zero) {
                Spacer()
                Text("The Little Things")
                    .textStyle(size: 32)
                Spacer()

            }
        }
        .padding(.leading, 24)
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
    
    var moreBtn: some View {
        Text("more")
            .textStyle(size: 12, color: AppColor.color(hex: 0x7F7F7F), fontFamily: .poppinsRegular)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.clear)
                    .stroke(AppColor.color(hex: 0x7F7F7F), style: .init(lineWidth: 1))
            }
            .padding(.top, 5)
            .padding(.leading, 54)
            .padding(.bottom, 24)

    }
    
    @ViewBuilder func addNewBtn(answerCount: Int, question: ThreadQuestion) -> some View {
       let answerCount = max(answerCount, 1)
       Button {
           homeCoordinator.push(HomeRoute.addNewAnswer(question: question.toQuestion()))
       } label: {
           Text("+ add new")
               .textStyle(size: 12, color: AppColor.color(hex: 0xffffff), fontFamily: .poppinsRegular)
               .padding(.horizontal, 12)
               .padding(.vertical, 4)
               .background {
                   RoundedRectangle(cornerRadius: 12)
                       .fill(AppColor.color(hex: 0x000000))
               }
       }
       .padding(.top, 5)
       .padding(.bottom, 76 / CGFloat(answerCount))
       .padding(.leading, 54)

    }
}
