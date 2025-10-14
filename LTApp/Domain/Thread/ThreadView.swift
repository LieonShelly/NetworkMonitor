//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

struct ThreadView: View {
    @EnvironmentObject var homeCoordinator: HomeCoordinator
    @EnvironmentObject var appCoordinator: AppCoordinator
    @ObservedObject var viewModel: ThreadViewModel
    
    init(viewModel: ThreadViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: .zero) {
            titleView
            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: .zero) {
                    ForEach(viewModel.questionList, id: \.id) { question in
                        VStack(alignment: .leading, spacing: .zero) {
                            questionRow(question.title)
                            VStack(alignment: .leading, spacing: .zero) {
                                ForEach(0 ..< 3) { index in
                                    if index < question.answers.count {
                                        let answer = question.answers[index]
                                        answerRow(answer.content, icon: .calendarDripper)
                                            .onTapGesture {
                                                homeCoordinator.push(HomeRoute.reflectionDetail)
                                            }
                                    }
                                }
                                if question.answers.count >= 3 {
                                    moreBtn
                                } else {
                                    addNewBtn(answerCount: question.answers.count)
                                }
                                Spacer()
                            }
                            .padding(.top, 10)
                        }
                        .overlay(alignment: .leading) {
                            line()
                        }
                    }
                    
                 footer
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
                
            }
        }
      
    }
    
    func answerRow(_ value: String, icon: ImageResource? = nil) -> some View {
        HStack(spacing: .zero) {
            Rectangle()
                .fill(Color.clear)
                .frame(width: 30, height: 30)
                .overlay {
                    if let icon {
                        Image(icon)
                    } else {
                        Circle()
                            .fill(AppColor.color(hex: 0x848484))
                            .frame(width: 4, height: 4)
                    }
                }
                .padding(.trailing, 24)
               
            Text(value)
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
        HStack(spacing: .zero) {
            Button {
                homeCoordinator.push(HomeRoute.questionLib)
            } label: {
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 40, height: 40)
            }
            Spacer()
            Text("The Little Things")
                .textStyle(size: 36)
            Spacer()

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
    }
    
    var moreBtn: some View {
        Button {
            
        } label: {
            Text("more")
                .textStyle(size: 12, color: AppColor.color(hex: 0x7F7F7F), fontFamily: .poppinsRegular)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.clear)
                        .stroke(AppColor.color(hex: 0x7F7F7F), style: .init(lineWidth: 1))
                }
        }
        .padding(.top, 5)
        .padding(.leading, 54)
        .padding(.bottom, 24)

    }
    
    func addNewBtn(answerCount: Int) -> some View {
        Button {
            
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
