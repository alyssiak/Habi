//
//  StatisticsViewModel.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 10.07.2026.
//

import Foundation
import Combine

final class StatisticsViewModel {
    @Published private(set) var state = StatisticsViewState(
        selectedPeriod: .weekly,
        title: "This Week's Progress",
        subtitle: "Overall completion",
        overallProgress: 0,
        overallPercentText: "0%",
        habitProgressItems: [],
        monthDays: [],
        selectedMonthText: nil,
        canShowNextMonth: false,
        topHabitProgressItems: []
    )

    private let repository: HabitRepositoryProtocol
    private let statsCalculator: HabitStatsCalculator
    private var selectedPeriod: StatisticsPeriod = .weekly
    private var cancellables = Set<AnyCancellable>()
    private var selectedMonthDate = Date()
    
    init(
        repository: HabitRepositoryProtocol,
        statsCalculator: HabitStatsCalculator
    ) {
        self.repository = repository
        self.statsCalculator = statsCalculator

        bindRepositoryChanges()
    }

    func loadStatistics() {
        switch selectedPeriod {
        case .weekly:
            state = makeWeeklyState()
        case .monthly:
            state = makeMonthlyState()
        }
    }

    func selectPeriod(_ period: StatisticsPeriod) {
        selectedPeriod = period
        loadStatistics()
    }

    func showPreviousMonth() {
        guard selectedPeriod == .monthly else { return }

        selectedMonthDate = Calendar.current.date(
            byAdding: .month,
            value: -1,
            to: selectedMonthDate
        ) ?? selectedMonthDate

        loadStatistics()
    }

    func showNextMonth() {
        guard selectedPeriod == .monthly, canShowNextMonth() else { return }

        selectedMonthDate = Calendar.current.date(
            byAdding: .month,
            value: 1,
            to: selectedMonthDate
        ) ?? selectedMonthDate

        loadStatistics()
    }

    private func bindRepositoryChanges() {
        repository.changesPublisher
            .sink { [weak self] in
                self?.loadStatistics()
            }
            .store(in: &cancellables)
    }
}

//MARK: - Weekly
private extension StatisticsViewModel {
    func makeWeeklyState() -> StatisticsViewState {
        let habits = repository.fetchHabits()
        let weekDates = makeCurrentWeekDates()

        let items = habits.map { habit in
            makeWeeklyProgressItem(
                habit: habit,
                weekDates: weekDates
            )
        }

        let completedCount = items.reduce(0) { result, item in
            result + item.completedCount
        }

        let totalCount = items.reduce(0) { result, item in
            result + item.totalCount
        }

        let overallProgress = makeProgress(
            completedCount: completedCount,
            totalCount: totalCount
        )

        return StatisticsViewState(
            selectedPeriod: .weekly,
            title: makeTitle(for: .weekly),
            subtitle: "Overall completion",
            overallProgress: overallProgress,
            overallPercentText: makePercentText(overallProgress),
            habitProgressItems: items,
            monthDays: [],
            selectedMonthText: nil,
            canShowNextMonth: false,
            topHabitProgressItems: []
        )
    }

    func makeWeeklyProgressItem(
        habit: Habit,
        weekDates: [Date]
    ) -> HabitProgressItem {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let days = weekDates.map { date in
            let startOfDay = calendar.startOfDay(for: date)

            return HabitProgressDay(
                title: makeWeekdayTitle(from: date),
                isCompleted: repository.isHabitCompleted(habit, on: date),
                isFuture: startOfDay > today
            )
        }

        let completedCount = days.filter { $0.isCompleted }.count
        let totalCount = days.filter { !$0.isFuture }.count
        let progress = makeProgress(completedCount: completedCount, totalCount: totalCount)
        let records = repository.fetchRecords(for: habit)
        let stats = statsCalculator.makeStats(from: records)

        return HabitProgressItem(
            title: habit.title ?? "Untitled habit",
            colorHex: habit.colorHex,
            completedCount: completedCount,
            totalCount: totalCount,
            progress: progress,
            progressText: makePercentText(progress),
            completedText: "\(completedCount)/\(totalCount) completed",
            streak: stats.currentStreak,
            days: days
        )
    }

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

    func makeWeekdayTitle(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "E"

        return String(formatter.string(from: date).prefix(1))
    }
}

//MARK: - Monthly
private extension StatisticsViewModel {
    func makeMonthlyState() -> StatisticsViewState {
        let habits = repository.fetchHabits()
        let monthDates = makeMonthDates(for: selectedMonthDate)
        let monthDays = makeMonthProgressDays(habits: habits, monthDates: monthDates)
        let pastDays = monthDays.filter { !$0.isFuture }
        let overallProgress = makeAverageProgress(from: pastDays)
        let topHabitProgressItems = makeTopHabitProgressItems(
            habits: habits,
            monthDates: monthDates
        )

        return StatisticsViewState(
            selectedPeriod: .monthly,
            title: makeTitle(for: .monthly),
            subtitle: "Overall completion",
            overallProgress: overallProgress,
            overallPercentText: makePercentText(overallProgress),
            habitProgressItems: [],
            monthDays: monthDays,
            selectedMonthText: makeMonthTitle(from: selectedMonthDate),
            canShowNextMonth: canShowNextMonth(),
            topHabitProgressItems: topHabitProgressItems
        )
    }

    func makeTopHabitProgressItems(
        habits: [Habit],
        monthDates: [Date]
    ) -> [TopHabitProgressItem] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let pastDates = monthDates.filter { date in
            calendar.startOfDay(for: date) <= today
        }

        return habits
            .map { habit in
                let completedCount = pastDates.filter { date in
                    repository.isHabitCompleted(habit, on: date)
                }.count

                let progress = makeProgress(
                    completedCount: completedCount,
                    totalCount: pastDates.count
                )

                return TopHabitProgressItem(
                    title: habit.title ?? "Untitled habit",
                    colorHex: habit.colorHex,
                    progress: progress,
                    progressText: makePercentText(progress),
                    completedText: "\(completedCount)/\(pastDates.count)"
                )
            }
            .sorted { first, second in
                first.progress > second.progress
            }
            .prefix(4)
            .map { $0 }
    }

    func makeMonthProgressDays(
        habits: [Habit],
        monthDates: [Date]
    ) -> [MonthProgressDay] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return monthDates.map { date in
            let startOfDay = calendar.startOfDay(for: date)
            let isFuture = startOfDay > today

            let completedCount = habits.filter { habit in
                repository.isHabitCompleted(habit, on: date)
            }.count

            let progress = isFuture ? 0 : makeProgress(
                completedCount: completedCount,
                totalCount: habits.count
            )

            return MonthProgressDay(
                title: makeMonthDayTitle(from: date),
                progress: progress,
                isFuture: isFuture
            )
        }
    }

    func makeMonthDates(for date: Date) -> [Date] {
        let calendar = Calendar.current
        let selectedDate = calendar.startOfDay(for: date)

        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate),
              let range = calendar.range(of: .day, in: .month, for: selectedDate) else {
            return [selectedDate]
        }

        return range.compactMap { day in
            calendar.date(
                byAdding: .day,
                value: day - 1,
                to: monthInterval.start
            )
        }
    }

    func makeMonthDayTitle(from date: Date) -> String {
        let day = Calendar.current.component(.day, from: date)
        return "\(day)"
    }
}

//MARK: - Helpers
private extension StatisticsViewModel {
    func makeProgress(completedCount: Int, totalCount: Int) -> Double {
        guard totalCount > 0 else {
            return 0
        }

        return Double(completedCount) / Double(totalCount)
    }

    func makePercentText(_ progress: Double) -> String {
        "\(Int((progress * 100).rounded()))%"
    }

    func makeAverageProgress(from days: [MonthProgressDay]) -> Double {
        guard !days.isEmpty else {
            return 0
        }

        let totalProgress = days.reduce(0) { result, day in
            result + day.progress
        }

        return totalProgress / Double(days.count)
    }

    func makeMonthTitle(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }

    func canShowNextMonth() -> Bool {
        let calendar = Calendar.current

        guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: selectedMonthDate),
              let nextMonthStart = calendar.dateInterval(of: .month, for: nextMonth)?.start,
              let currentMonthStart = calendar.dateInterval(of: .month, for: Date())?.start else {
            return false
        }

        return nextMonthStart <= currentMonthStart
    }

    func makeTitle(for period: StatisticsPeriod) -> String {
        switch period {
        case .weekly:
            return "This Week's Progress"
        case .monthly:
            return "This Month's Progress"
        }
    }
}
