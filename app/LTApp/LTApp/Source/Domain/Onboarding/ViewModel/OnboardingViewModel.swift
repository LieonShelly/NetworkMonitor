//
//  LTApp, This code is protected by intellectual property rights.
//

import Combine

final class OnboardingViewModel: ObservableObject, @unchecked Sendable {
    @MainActor @Published var list: [Category] = []
    @MainActor @Published var sentence: OnboardingSentence?
    
    private let service: any AppDataWithAuthorizationServiceful
    
    init(service: any AppDataWithAuthorizationServiceful) {
        self.service = service
    }
    
    
    func fetchData() async {
        do {
            let sentence =  try await service.fetchOnboardingSentenceUseCase.execute()
            let list =  try await service.fetchCategoriesUseCase.execute()
            await MainActor.run {
                self.list = list
                self.sentence = sentence
            }
        } catch {
            print(error)
        }
    }
}
