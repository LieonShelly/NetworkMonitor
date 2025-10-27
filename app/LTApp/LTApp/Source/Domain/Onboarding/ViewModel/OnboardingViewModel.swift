//
//  LTApp, This code is protected by intellectual property rights.
//

import Combine

final class OnboardingViewModel: ObservableObject, @unchecked Sendable {
    @MainActor @Published var list: [Category] = []
    
    private let service: any AppDataWithAuthorizationServiceful
    
    init(service: any AppDataWithAuthorizationServiceful) {
        self.service = service
    }
    
    
    func fetchData() async {
        do {
            let list =  try await service.fetchCategoriesUseCase.execute()
            await MainActor.run {
                self.list = list
            }
        } catch {
            print(error)
        }
    }
}
