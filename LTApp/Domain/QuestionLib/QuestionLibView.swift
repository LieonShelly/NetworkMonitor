//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

struct QuestionLibView: View {
    @EnvironmentObject var homeCoordinator: HomeCoordinator
    @StateObject var viewModel: QuestionLibViewModel
    
    init(viewModel: QuestionLibViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            Rectangle()
                .fill(Color.clear)
                .frame(height: 36)
            LazyVStack(spacing: .zero) {
                ForEach(viewModel.categories, id: \.id) { category in
                    VStack(spacing: .zero) {
                        sectionHeader(category.name)
                        ForEach(category.questions, id: \.id) { question in
                            QuestionRow(text: question.title, isPinned: question.pinned)
                                .onTapGesture {
                                    Task.detached {
                                        await viewModel.pinQuesition(question)
                                    }
                                }
                        }
                    }
                    .padding(.bottom, 36)
                }
            }
         
        }
        .defaultBackground()
        .defaultNavigationBar("Question Library") {
            homeCoordinator.pop()
        }
        .task {
            do {
                try await viewModel.fetchData()
            } catch {
                
            }
        }
    }
    
    func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .textStyle(size: 24)
            Spacer()
        }
        .padding(.leading, 42)
    }
}

