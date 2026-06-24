//
//  ArchivedHabitsViewModel.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 24.06.2026.
//

import Foundation
import Combine
import CoreData

final class ArchivedHabitsViewModel {
    private let repository: HabitRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    @Published private(set) var habits: [ArchivedHabitModel] = []
    
    init(repository: HabitRepositoryProtocol) {
        self.repository = repository
        
        repository.changesPublisher
            .sink { [weak self] in
                self?.loadArchivedHabits()
            }
            .store(in: &cancellables)
    }
    
    func loadArchivedHabits() {
        habits = repository.fetchArchivedHabits().map { habit in
            ArchivedHabitModel(
                id: habit.objectID,
                emoji: habit.emoji ?? "",
                title: habit.title ?? "",
                descriptionText: habit.descriptionText ?? "",
                colorHex: habit.colorHex ?? ""
            )
        }
    }
    
    func restoreHabit(for habitId: NSManagedObjectID) {
        repository.restoreHabit(for: habitId)
        loadArchivedHabits()
    }
    
    func permanentlyDeleteHabit(for habitId: NSManagedObjectID) {
        repository.permanentlyDeleteHabit(for: habitId)
        loadArchivedHabits()
    }

    func permanentlyDeleteAllArchivedHabits() {
        repository.permanentlyDeleteAllArchivedHabits()
        loadArchivedHabits()
    }
}
