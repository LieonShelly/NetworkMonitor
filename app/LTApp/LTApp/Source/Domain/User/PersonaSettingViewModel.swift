//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//
//
//  PersonaSettingViewModel.swift
//  LTApp
//

import SwiftUI
import Combine

@MainActor
final class PersonaSettingViewModel: ObservableObject {
    let dataService: any AppDataWithAuthorizationServiceful
    @Published var personas: [PersonaOption] = []
    @Published var selectedId: String?
    @Published var isSaving: Bool = false
    private var originalSelectedId: String?
    private var cancellables: Set<AnyCancellable> = .init()
    
    var hasChanges: Bool {
        selectedId != nil && selectedId != originalSelectedId
    }
    
    init(dataService: any AppDataWithAuthorizationServiceful) {
        self.dataService = dataService
        dataService.userManagementService
            .user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                guard let self, let user else { return }
                self.selectedId = user.reportPersonaId
                self.originalSelectedId = user.reportPersonaId
                
            }
            .store(in: &cancellables)
    }
    
    func fetchPersonas() async {
        do {
            let list = try await dataService.fetchPersonasUseCase.execute()
            self.personas = list
        } catch {
            print("fetchPersonas error: \(error)")
        }
    }
    
    func save() async {
        guard let selectedId, hasChanges else { return }
        isSaving = true
        do {
            let _ = try await dataService.updateReportPersonaUseCase.execute(personaId: selectedId)
            self.originalSelectedId = selectedId
        } catch {
            print("updateReportPersona error: \(error)")
        }
        isSaving = false
        try? await dataService.userManagementService.fetchUserInfo()
    }
}
