//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Combine
import Foundation

@MainActor
final class NewUserHomeViewModel: ObservableObject, @unchecked Sendable {
    let dataService: any AppDataWithAuthorizationServiceful
    
    @Published var nickname: String = "Set your display name"
    private var cancellables: Set<AnyCancellable> = .init()
    
    init(dataService: any AppDataWithAuthorizationServiceful) {
        self.dataService = dataService
        dataService.userManagementService
            .user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                guard let self, let user else{ return }
                self.nickname = user .nickname ?? "Set your display name"
            }
            .store(in: &cancellables)
    }
    
    func fetchUserInfo() async throws  {
        try await dataService.userManagementService.fetchUserInfo()
    }
    
}
