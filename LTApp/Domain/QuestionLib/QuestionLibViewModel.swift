//
//  LTApp, This code is protected by intellectual property rights.
//


import Combine

final class QuestionLibViewModel: ObservableObject, @unchecked Sendable {
    @MainActor @Published var categories: [Category] = []
    private let service: any AppDataWithAuthorizationServiceful
    
    init(service: any AppDataWithAuthorizationServiceful) {
        self.service = service
    }
    
    func fetchData() async throws {
        let categories = try await service.fetchQuestionsWithCategoryUseCase.execute()
        await MainActor.run {
            self.categories = categories
        }
    }
    
    func pinQuesition(_ question: Question) async {
        do {
            try await service.pinQuestionUseCase.execute(questionId: question.id, pinned: !question.pinned)
            for cateIndx in await (0 ..< categories.count) {
                var category = await categories[cateIndx]
                guard let index = category.questions.firstIndex(where:  { $0.id == question.id }) else {
                     continue
                }
                var question = category.questions[index]
                question.pinned = !question.pinned
                category.questions[index] = question
                await MainActor.run {
                    categories[cateIndx] = category
                }
                break
            }
        } catch {
            print(error)
        }
    }
    
    deinit {
        print("deinit-QuestionLibViewModel")
    }
}
