//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import SwiftUI
import Combine

@MainActor
final class AboutMeViewModel: ObservableObject, @unchecked Sendable {
    let dataService: any AppDataWithAuthorizationServiceful
    
    @Published var nickname: String = ""
    @Published var email: String = ""
    @Published var isEditing: Bool = false
    @Published var isSaving: Bool = false
    private var cancellables: Set<AnyCancellable> = .init()
    private var originalNickname: String = ""
    
    init(dataService: any AppDataWithAuthorizationServiceful) {
        self.dataService = dataService
        dataService.userManagementService
            .user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                guard let self, let user else{ return }
                self.nickname = user .nickname ?? ""
                self.originalNickname = user.nickname ?? ""
                self.email = user.email ?? ""
            }
            .store(in: &cancellables)
    }
    
    var hasChanges: Bool {
        !nickname.trimmingCharacters(in: .whitespaces).isEmpty
            && nickname != originalNickname
    }
    
    var displayName: String {
        originalNickname.isEmpty ? "" : originalNickname
    }
    
    func fetchUserInfo() async throws  {
        try await dataService.userManagementService.fetchUserInfo()
    }
    
    func saveNickname() async {
        let trimmed = nickname.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, trimmed != originalNickname else { return }
        
        isSaving = true
        do {
            let result = try await dataService.updateNicknameUseCase.execute(nickname: trimmed)
            self.originalNickname = result.nickname ?? ""
            self.nickname = result.nickname ?? ""
            self.isEditing = false
        } catch {
            print("saveNickname error: \(error)")
        }
        isSaving = false
        try? await dataService.userManagementService.fetchUserInfo()
    }
    
    func logout() async {
        try? dataService.userManagementService.clear()
        try? await dataService.authUseCasse.logout()
    }
}
