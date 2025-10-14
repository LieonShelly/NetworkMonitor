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
    
    deinit {
        print("deinit-QuestionLibViewModel")
    }
}
