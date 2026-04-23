//
//  ReminderSettingViewModel.swift
//  LTApp
//

import SwiftUI

@MainActor
final class ReminderSettingViewModel: ObservableObject {
    let dataService: any AppDataWithAuthorizationServiceful
    let slots: [(slot: ReminderSlot, label: String)] = [
        (.morning, "Morning"),
        (.afternoon, "Afternoon"),
        (.evening, "Evening")
    ]
    @Published var selectedSlot: ReminderSlot? = .evening
    @Published var isEnabled: Bool = true
    @Published var isSaving: Bool = false
    
    private var originalSlot: ReminderSlot?
    private var originalEnabled: Bool = true
    
    var hasChanges: Bool {
        if isEnabled != originalEnabled { return true }
        if isEnabled && selectedSlot != originalSlot { return true }
        return false
    }
    
    init(dataService: any AppDataWithAuthorizationServiceful) {
        self.dataService = dataService
    }
    
    func fetchReminder() async {
        do {
            let result = try await dataService.fetchReminderUseCase.execute()
            self.selectedSlot = result.slot
            self.isEnabled = result.slot != nil
            self.originalSlot = result.slot
            self.originalEnabled = result.slot != nil
        } catch {
            print("fetchReminder error: \(error)")
        }
    }
    
    func save() async {
        guard hasChanges else { return }
        isSaving = true
        do {
            let slot: ReminderSlot? = isEnabled ? selectedSlot : nil
            let result = try await dataService.updateReminderUseCase.execute(slot: slot)
            self.originalSlot = result.slot
            self.originalEnabled = result.slot != nil
        } catch {
            print("updateReminder error: \(error)")
        }
        isSaving = false
    }
}
