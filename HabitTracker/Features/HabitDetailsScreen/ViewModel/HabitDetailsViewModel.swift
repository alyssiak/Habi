//
//  HabitDetailsViewModel.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 16.06.2026.
//

import CoreData
import Foundation
import Combine


final class HabitDetailsViewModel {
    //MARK: - Properties
    @Published private(set) var viewState: HabitDetailsViewState?
    private let statsCalculator: HabitStatsCalculating
    private let habitId: NSManagedObjectID
    private let repository: HabitRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    private var selectedMonth = Date()
    
    //MARK: - Init
    init(habitId: NSManagedObjectID, repository: HabitRepositoryProtocol, statsCalculator: HabitStatsCalculating) {
        self.habitId = habitId
        self.repository = repository
        self.statsCalculator = statsCalculator
        
        repository.changesPublisher
            .sink { [weak self] in
                self?.loadDetails()
            }
            .store(in: &cancellables)
    }
    
    //MARK: - Public methods
    func loadDetails() {
        guard let habit = repository.fetchHabit(for: habitId) else {
            return
        }
        
        let records = repository.fetchRecords(for: habitId)
        
        viewState = HabitDetailsViewState(
            header: makeHeaderModel(from: habit),
            form: makeFormModel(from: habit),
            calendar: makeCalendarModel(for: selectedMonth,  records: records),
            stats: makeStatsModel(records: records)
        )
    }
    
    func toggleDay(_ date: Date) {
        let calendar = Calendar.current
        let selectedDay = calendar.startOfDay(for: date)
        let today = calendar.startOfDay(for: Date())
        
        guard selectedDay <= today else {
            return
        }
        
        repository.toggleHabitRecord(for: habitId, date: selectedDay)
    }
    
    func showPreviousMonth() {
        changeMonth(by: -1)
    }
    
    func showNextMonth() {
        changeMonth(by: 1)
    }
    
    //MARK: - Private methods
    private func changeMonth(by value: Int) {
        let calendar = Calendar.current
        
        guard let newMonth = calendar.date(
            byAdding: .month,
            value: value,
            to: selectedMonth
        ) else {
            return
        }
        
        selectedMonth = newMonth
        loadDetails()
    }
    
    private func makeCalendarModel(for selectedMonth: Date, records: [HabitRecord]) -> HabitDetailsCalendarModel {
        let monthTitle = makeMonthTitle(from: selectedMonth)
        let yearTitle = makeYearTitle(from: selectedMonth)
        let days = makeMonthDays(for: selectedMonth, records: records)
        
        return HabitDetailsCalendarModel(
            monthTitle: monthTitle,
            yearTitle: yearTitle,
            days: days
        )
    }
    
    private func makeStatsModel(records: [HabitRecord]) -> HabitDetailsStatsModel {
        let stats = statsCalculator.makeStats(from: records)
       
        return HabitDetailsStatsModel(
            completedDays: stats.completedDays,
            bestStreak: stats.bestStreak,
            currentStreak: stats.currentStreak
        )
    }
    
    private func makeMonthTitle(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: date)
    }
    
    private func makeYearTitle(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: date)
    }
    
    private func makeMonthDays(for selectedMonth: Date, records: [HabitRecord]) -> [HabitDetailsCalendarDayCellModel] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: selectedMonth)
        guard let firstDayOfMonth = calendar.date(from: components) else { return [] }
        
        //кол-во дней в месяца
        let range = calendar.range(of: .day, in: .month, for: selectedMonth)
        let numberOfDays = range?.count ?? 0
        
        //узнать день недели первого числа
        let weekday = calendar.component(.weekday, from: firstDayOfMonth)
        let leadingEmptyDays = (weekday + 5) % 7
        
        var days: [HabitDetailsCalendarDayCellModel] = []
        
        let emptyModels = Array(
            repeating: HabitDetailsCalendarDayCellModel(date: nil, dayNumber: nil, state: nil),
            count: leadingEmptyDays
        )
        
        days.append(contentsOf: emptyModels)
        let today = calendar.startOfDay(for: Date())
        
        for day in 1...numberOfDays {
            guard let date = calendar.date(
                byAdding: .day,
                value: day - 1,
                to: firstDayOfMonth
            ) else { continue }
            
            let dayDate = calendar.startOfDay(for: date)
            
            let isCompleted = hasCompletedRecord(
                on: dayDate,
                records: records,
                calendar: calendar
            )
            
            let state: HabitCalendarDayState
            
            if dayDate > today {
                state = .future
            } else if isCompleted {
                state = .completed
            } else {
                state = .missed
            }
            
            let model = HabitDetailsCalendarDayCellModel(date: dayDate, dayNumber: day, state: state)
            
            days.append(model)
        }
        
        return days
    }
    
    private func hasCompletedRecord(on date: Date, records: [HabitRecord], calendar: Calendar) -> Bool {
        records.contains { record in
            guard let recordDate = record.date, record.isCompleted else {
                return false
            }
            
            return calendar.isDate(recordDate, inSameDayAs: date)
        }
    }
    
    private func makeHeaderModel(from habit: Habit) -> HabitDetailsHeaderModel {
        HabitDetailsHeaderModel(
            title: habit.title ?? "",
            emoji: habit.emoji ?? "",
            colorHex: habit.colorHex ?? ""
        )
    }
    
    private func makeFormModel(from habit: Habit) -> HabitFormModel {
        HabitFormModel(
            id: habit.objectID,
            title: habit.title ?? "",
            emoji: habit.emoji ?? "",
            colorHex: habit.colorHex ?? ""
        )
    }
}

