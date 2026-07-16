//
//  ViewModel.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 30.04.2026.
//

import Foundation
import CoreData
import Combine

final class HabitTrackerViewModel {
    //MARK: - Properties
    @Published private(set) var quote: Quote?
    private let statsCalculator: HabitStatsCalculating
    private let repository: HabitRepositoryProtocol
    private let profileRepository: ProfileRepositoryProtocol
    private let quoteService: QuoteServiceProtocol
    private let calendarBuilder: HabitCalendarBuilding
    private var cancellables = Set<AnyCancellable>()
    
    private(set) var habits: [Habit] = []
    
    var onUpdate: (() -> Void)?
    var onHabitsChanged: (([HabitCardModel]) -> Void)?
    var onProfileChanged: ((HabitHeaderProfileState) -> Void)?

    //MARK: - Init
    init(
        repository: HabitRepositoryProtocol,
        quoteService: QuoteServiceProtocol,
        statsCalculator: HabitStatsCalculating,
        calendarBuilder: HabitCalendarBuilding,
        profileRepository: ProfileRepositoryProtocol
    ) {
        self.repository = repository
        self.quoteService = quoteService
        self.statsCalculator = statsCalculator
        self.calendarBuilder = calendarBuilder
        self.profileRepository = profileRepository
        
        repository.changesPublisher
            .sink { [weak self] in
                self?.loadHabits()
            }
            .store(in: &cancellables)
        
        profileRepository.changesPublisher
            .sink { [weak self] in
                self?.loadProfile()
            }
            .store(in: &cancellables)
    }

    //MARK: - Public Methods
    func loadHabits() {
        habits = repository.fetchHabits()

        let models = habits.map { habit in
            mapToCardModel(habit:habit)
    }
        onHabitsChanged?(models)
    }

    func addHabit(title: String, emoji: String?, colorHex: String?, descriptionText: String?) {
        repository.addHabit(title: title, emoji: emoji, colorHex: colorHex, descriptionText: descriptionText)
        loadHabits()
    }

    func updateHabit(for habitId: NSManagedObjectID, title: String, emoji: String?, colorHex: String?, descriptionText: String?) {
        guard let habit = habits.first(where: {$0.objectID == habitId}) else {
            return
        }

        repository.updateHabit(habit, title: title, emoji: emoji, colorHex: colorHex, descriptionText: descriptionText)
        loadHabits()
    }

    func deleteHabit(for habitId: NSManagedObjectID) {
        guard let habit = habits.first(where: { $0.objectID == habitId }) else {
            return
        }

        repository.deleteHabit(habit)
        loadHabits()
    }

    func restoreHabit(for habitId: NSManagedObjectID) {
        repository.restoreHabit(for: habitId)
        loadHabits()
    }

    func toggleToday(for habitId: NSManagedObjectID) {
        repository.toggleToday(for: habitId)
        loadHabits()
    }

    func toggleHabitRecord(for habitId: NSManagedObjectID, date: Date) {
        guard let habit = habits.first(where: { $0.objectID == habitId }) else {
            return
        }
        repository.toggleHabitRecord(habit, date: date)
        loadHabits()
        
    }

    func loadQuote() async {
        do {
            let quote = try await quoteService.fetchQuote()
            await MainActor.run {
                self.quote = quote
            }
        } catch {
            print(error)
            
            await MainActor.run {
                self.quote = nil
            }
        }
    }
    
    //MARK - Repository
    func loadProfile() {
        let profile = profileRepository.fetchProfile()

        onProfileChanged?(
            HabitHeaderProfileState(
                name: profile.name,
                avatarData: profile.avatarData
            )
        )
    }
    
    //MARK: - Private Helpers
    private func mapToCardModel(habit: Habit) -> HabitCardModel {
        let records = habit.records as? Set<HabitRecord> ?? []
        let recordsArray = Array(records)
        let today = Date()

        let completedDates = recordsArray
            .filter { $0.isCompleted }
            .compactMap { $0.date }
        
        
        let days = calendarBuilder.buildDays(
            createdAt: habit.createdAt,
            completedDates: completedDates,
            today: today
        )
        
        let isDoneToday = calendarBuilder.isCompletedToday(
            completedDates: completedDates,
            today: today
        )
        
        let stats = statsCalculator.makeStats(from: recordsArray)
        
        let completedDays = days.filter {
            $0.state == .completed
        }.count

        let totalDays = days.count
        
        return HabitCardModel(
            id: habit.objectID,
            emoji: habit.emoji ?? "",
            colorHex: habit.colorHex ?? "",
            descriptionText: habit.descriptionText ?? "",
            title: habit.title ?? "",
            isDoneToday: isDoneToday,
            days: days,
            streak: stats.currentStreak,
            completedDays: completedDays,
            totalDays: totalDays
        )
    }
}
