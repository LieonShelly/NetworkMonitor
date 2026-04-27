//
//  LTApp, This code is protected by intellectual property rights.
//

import Combine

final class WelcomeViewModel: ObservableObject, @unchecked Sendable {
    @MainActor @Published var sentence: OnboardingSentence?
    private(set) var category: Category
    private let service: any AppDataWithAuthorizationServiceful
    
    init(service: any AppDataWithAuthorizationServiceful,
         category: Category) {
        self.category = category
        self.service = service
    }
    
    
    func fetchData() async {
        do {
            let sentence =  try await service.fetchOnboardingSentenceUseCase.execute()
            await MainActor.run {
                self.sentence = sentence
            }
        } catch {
            print(error)
        }
    }
}
