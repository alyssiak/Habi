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
    private let quoteService: QuoteServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private(set) var habits: [Habit] = []
    var onUpdate: (() -> Void)?
    var onHabitsChanged: (([HabitCardModel]) -> Void)?

    //MARK: - Init
    init(repository: HabitRepositoryProtocol, quoteService: QuoteServiceProtocol, statsCalculator: HabitStatsCalculating) {
        self.repository = repository
        self.quoteService = quoteService
        self.statsCalculator = statsCalculator
        
        repository.changesPublisher
            .sink { [weak self] in
                self?.loadHabits()
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

    func addHabit(title: String, emoji: String?, colorHex: String?) {
        repository.addHabit(title: title, emoji: emoji, colorHex: colorHex)
        loadHabits()
    }

    func updateHabit(for habitId: NSManagedObjectID, title: String, emoji: String?, colorHex: String?) {
        guard let habit = habits.first(where: {$0.objectID == habitId}) else {
            return
        }

        repository.updateHabit(habit, title: title, emoji: emoji, colorHex: colorHex)
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
    //MARK: - Private Helpers
    private func mapToCardModel(habit: Habit) -> HabitCardModel {
        let records = habit.records as? Set<HabitRecord> ?? []
        let recordsArray = Array(records)

        //массив из 30 HabitCalendarDay
        let days = buildCalendarDays(
            createdAt: habit.createdAt,
            records: recordsArray
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
            title: habit.title ?? "",
            isDoneToday: isDoneToday(records: recordsArray),
            days: days,
            streak: stats.currentStreak,
            completedDays: completedDays,
            totalDays: totalDays
        )
    }

    private func isDoneToday(records: [HabitRecord]) -> Bool {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        guard let nextDay = calendar.date(byAdding: .day, value: 1, to: startOfToday) else {
            return false
        }

        return records.contains { record in
            guard let date = record.date else {
                return false
            }

            return date >= startOfToday &&
            date < nextDay &&
            record.isCompleted

        }
    }

    private func buildCalendarDays(createdAt: Date?, records: [HabitRecord]) -> [HabitCalendarDay] {
        guard let createdAt else { return [] }

        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: createdAt)
        let today = calendar.startOfDay(for: Date())

        // считаем разницу междой датой создания привычки и текующим днем
        let totalDaysPassed = calendar.dateComponents([.day], from: startDate, to: today).day ?? 0
        let currentBlockIndex = totalDaysPassed / 30
        guard let blockStartDate = calendar.date(byAdding: .day, value: currentBlockIndex * 30, to: startDate) else {
            return []
        }
        var days: [HabitCalendarDay] = []

        for offset in 0..<30 {
            guard let date = calendar.date(byAdding: .day, value: offset, to: blockStartDate) else {
                continue
            }

            let isCompleted = hasCompletedRecord(
                on: date,
                records: records,
                calendar: calendar
            )

            let state: HabitCalendarDayState

            if date > today {
                state = .future
            } else if isCompleted {
                state = .completed
            } else {
                state = .missed
            }

            days.append(HabitCalendarDay(date: date, state: state))
        }

        return days
    }

    private func hasCompletedRecord(on date: Date, records: [HabitRecord], calendar: Calendar) -> Bool {
        return records.contains { record in
            guard let recordDate = record.date, record.isCompleted else {
                return false
            }

            return calendar.isDate(recordDate, inSameDayAs: date)
        }
    }
    
}
