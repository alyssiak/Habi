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
    private let statsCalculator: HabitStatsCalculating
    private let repository: HabitRepositoryProtocol
    private let profileRepository: ProfileRepositoryProtocol
    private let calendarBuilder: HabitCalendarBuilding
    private var cancellables = Set<AnyCancellable>()

    private(set) var habits: [Habit] = []

    var onUpdate: (() -> Void)?
    var onHabitsChanged: (([HabitCardModel]) -> Void)?
    var onTodayProgressChanged: ((TodayProgressState) -> Void)?
    var onProfileChanged: ((HabitHeaderProfileState) -> Void)?

    //MARK: - Init
    init(
        repository: HabitRepositoryProtocol,
        statsCalculator: HabitStatsCalculating,
        calendarBuilder: HabitCalendarBuilding,
        profileRepository: ProfileRepositoryProtocol
    ) {
        self.repository = repository
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
        onTodayProgressChanged?(makeTodayProgressState(from: habits))
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

    //MARK - Repository
    func loadProfile() {
        let profile = profileRepository.fetchProfile()

        onProfileChanged?(
            HabitHeaderProfileState(
                name: profile.name,
                avatarData: profile.avatarData,
                language: profile.language
            )
        )
    }

    func currentLanguage() -> AppLanguage {
        profileRepository.fetchProfile().language
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

private extension HabitTrackerViewModel {
    func makeTodayProgressState(from habits: [Habit]) -> TodayProgressState {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekDates = makeCurrentWeekDates()

        let completedTodayCount = habits.filter { habit in
            repository.isHabitCompleted(habit, on: today)
        }.count

        let totalTodayCount = habits.count
        let todayProgress = makeProgress(
            completedCount: completedTodayCount,
            totalCount: totalTodayCount
        )

        let weekDays = weekDates.map { date in
            let startOfDay = calendar.startOfDay(for: date)
            let completedCount = habits.filter { habit in
                repository.isHabitCompleted(habit, on: date)
            }.count

            let progress = startOfDay > today ? 0 : makeProgress(
                completedCount: completedCount,
                totalCount: habits.count
            )

            return TodayProgressDayState(
                weekdayTitle: makeWeekdayTitle(from: date),
                dayNumberText: makeDayNumberText(from: date),
                progress: progress,
                isToday: calendar.isDate(startOfDay, inSameDayAs: today),
                isFuture: startOfDay > today
            )
        }

        return TodayProgressState(
            title: "Today",
            completedText: "\(completedTodayCount)/\(totalTodayCount) completed",
            progress: todayProgress,
            weekDays: weekDays
        )
    }

    //MARK: Helpers
    func makeCurrentWeekDates() -> [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today) else {
            return [today]
        }

        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: weekInterval.start)
        }
    }

    func makeProgress(completedCount: Int, totalCount: Int) -> Double {
        guard totalCount > 0 else {
            return 0
        }

        return Double(completedCount) / Double(totalCount)
    }

    func makeWeekdayTitle(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "E"

        return formatter.string(from: date)
    }

    func makeDayNumberText(from date: Date) -> String {
        let day = Calendar.current.component(.day, from: date)
        return "\(day)"
    }

}
