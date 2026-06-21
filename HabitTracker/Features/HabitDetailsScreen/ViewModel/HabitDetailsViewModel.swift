//
//  HabitDetailsViewModel.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 16.06.2026.
//

import CoreData
import Foundation
import Combine

struct HabitDetailsCalendarModel {
    let monthTitle: String
    let yearTitle: String
    let days: [HabitDetailsCalendarDayCellModel]
}

final class HabitDetailsViewModel {
    @Published private(set) var calendarModel: HabitDetailsCalendarModel?

    private let habitId: NSManagedObjectID
    private let repository: HabitRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    private var selectedMonth = Date()
    
    init(habitId: NSManagedObjectID, repository: HabitRepositoryProtocol) {
        self.habitId = habitId
        self.repository = repository
        
        repository.changesPublisher
            .sink { [weak self] in
                self?.loadCalendar()
            }
            .store(in: &cancellables)
    }
    
    func loadCalendar() {
        calendarModel = makeCalendarModel(for: selectedMonth)
    }
    
    func toggleDay(_ date: Date) {
        repository.toggleHabitRecord(for: habitId, date: date)
    }
    
    func showPreviousMonth() {
        changeMonth(by: -1)
    }
    
    func showNextMonth() {
        changeMonth(by: 1)
    }
    
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
        loadCalendar()
    }
    
    private func makeCalendarModel(for selectedMonth: Date) -> HabitDetailsCalendarModel {
        let monthTitle = makeMonthTitle(from: selectedMonth)
        let yearTitle = makeYearTitle(from: selectedMonth)
        let records = repository.fetchRecords(for: habitId)
        let days = makeMonthDays(for: selectedMonth, records: records)
        
        return HabitDetailsCalendarModel(
            monthTitle: monthTitle,
            yearTitle: yearTitle,
            days: days
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
}
