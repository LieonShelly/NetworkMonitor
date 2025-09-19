//
//  LTApp, This code is protected by intellectual property rights.
//


import Combine

final class SplashViewModel: ObservableObject, @unchecked Sendable {
  @MainActor  @Published var sentence: OnboardingSentence?
    private let service: any AppDataWithAuthorizationServiceful
    
    init(service: any AppDataWithAuthorizationServiceful) {
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
