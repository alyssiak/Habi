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
        habitProgressItems: []
    )
    
    private let repository: HabitRepositoryProtocol
    private let statsCalculator: HabitStatsCalculator
    private var selectedPeriod: StatisticsPeriod = .weekly
    private var cancellables = Set<AnyCancellable>()
    
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
               state = makeWeeklyState(period: .weekly)
           case .monthly:
               state = makeWeeklyState(period: .monthly)
        }
    }
    
    func selectPeriod(_ period: StatisticsPeriod) {
        selectedPeriod = period
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

private extension StatisticsViewModel {
    func makeWeeklyState(period: StatisticsPeriod) -> StatisticsViewState {
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
            selectedPeriod: period,
            title: makeTitle(for: period),
            subtitle: "Overall completion",
            overallProgress: overallProgress,
            overallPercentText: makePercentText(overallProgress),
            habitProgressItems: items
        )
    }
    
    // Собирает одну карточку привычки за неделю.
    func makeWeeklyProgressItem(
        habit: Habit,
        weekDates: [Date]
    ) -> HabitProgressItem {
        let days = weekDates.map { date in
            HabitProgressDay(
                title: makeWeekdayTitle(from: date),
                isCompleted: repository.isHabitCompleted(habit, on: date),
                isFuture: Calendar.current.startOfDay(for: date) > Calendar.current.startOfDay(for: Date())
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
    
    // Возвращает даты текущей недели
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
    
    // делаем подпись дня недели (М, Т, В)
    func makeWeekdayTitle(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "E"
        
        return String(formatter.string(from: date).prefix(1))
    }
    
    //считаем процент
    func makeProgress(completedCount: Int, totalCount: Int) -> Double {
        guard totalCount > 0 else {
            return 0
        }
        return Double(completedCount) / Double(totalCount)
    }
    
    func makePercentText(_ progress: Double) -> String {
        "\(Int((progress * 100).rounded()))%"
    }
    
    //MARK: - Helpers
    func makeTitle(for period: StatisticsPeriod) -> String {
        switch period {
        case .weekly:
            return "This Week's Progress"
        case .monthly:
            return "This Month's Progress"
        }
    }
}
