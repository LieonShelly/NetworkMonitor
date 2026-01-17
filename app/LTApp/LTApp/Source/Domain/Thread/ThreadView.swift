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
            questionRow(question.title)
            let columnCount: Int = 7
            let colums = (0 ..< columnCount).map { _ in GridItem(.fixed(32), spacing: 8) }
            VStack(spacing: .zero) {
                LazyVGrid(columns: colums, spacing: 8) {
                    ForEach(question.answerItems) { answer in
                        let _ = print(":\(answer.type)")
                        switch answer.type {
                        case .addBtn:
                            addNewBtn
                        case let .noraml(answer):
                            IconView(answer: answer)
                        case .placeholder:
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: 32, height: 32)
                        }
                    }
                }
                HStack(spacing: 8, content: {
                    ForEach( 1 ... 7, id: \.self) { index in
                        if index == 7 {
                            addNewBtn
                        } else {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: 32, height: 32)
                        }
                    }
                })
                .overlay(alignment: .leading, content: {
                    Text("show more")
                        .textStyle(size: 10, color: AppColor.color(hex: 0xBFBFBF), fontFamily: .poppinsRegular)
                })
                .padding(.top, 8)
            }
         
            .padding(.leading, 20)
            .padding(.top, 8)
            
          
            
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
    
          
    func questionRow(_ value: String) -> some View {
        HStack(alignment: .top) {
            Image(.pinnedStar)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .padding(.top, 4)
            
            Text(value)
                .lineLimit(5)
                .textStyle(size: 24, fontFamily: .feltTipSeniorRegular)
                .padding(.leading, 20)
            Spacer()
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
    
    var addNewBtn: some View {
        Image(.threadAdd)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
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



struct IconView: View {
    let answer: Answer
    var size: CGSize = .init(width: 24, height: 24)
    
    var body: some View {
        iconView(answer, size: size)
    }
    
    @ViewBuilder
    func iconView(_ answer: Answer, size: CGSize = .init(width: 24, height: 24)) -> some View {
      
        if let icon = answer.icon {
            switch icon.status {
            case .pending:
                Image(.lock)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size.width, height: size.height)
            default:
                placeholderIcon
                    .frame(width: size.width, height: size.height)
                
//                if let url = icon.url {
//                    ThumbnailIconImageView(url: url) {
//                        placeholderIcon
//                    }
//                    .frame(width: size.width, height: size.height)
//                } else {
//                    placeholderIcon
//                        .frame(width: size.width, height: size.height)
//                }
            }
        } else {
            placeholderIcon
                .frame(width: size.width, height: size.height)
        }
    }
    
    var placeholderIcon: some View {
        Circle()
            .fill(Color.clear)
            .overlay(content: {
                Image(.calendarDripper)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            })
    }
    
    
}
