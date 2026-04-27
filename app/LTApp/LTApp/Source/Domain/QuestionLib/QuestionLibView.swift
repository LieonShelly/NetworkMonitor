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
        VStack(spacing: .zero) {
            FixedHeader(title: "Spark Library", size: .plain, backAction: {
                homeCoordinator.pop()
            })
            ScrollView {
                LazyVStack(spacing: .zero) {
                    ForEach(viewModel.categories, id: \.id) { category in
                        VStack(spacing: .zero) {
                            sectionHeader(category.name)
                            ForEach(category.questions, id: \.id) { question in
                                QuestionRow(text: question.title, isPinned: question.pinned) {
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
        }
        .toolbarVisibility(.hidden, for: .navigationBar)
        .defaultBackground()
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
                .textStyle(font: .title)
            Spacer()
        }
        .padding(.leading, 42)
    }
}

