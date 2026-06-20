//
//  HabitDetailsViewModel.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 16.06.2026.
//

import CoreData
import Foundation

struct HabitDetailsCalendarModel {
    let monthTitle: String
    let yearTitle: String
    let days: [HabitDetailsCalendarDayCellModel]
}

final class HabitDetailsViewModel {
    private let habitId: NSManagedObjectID
    private let repository: HabitRepositoryProtocol
    
    init(habitId: NSManagedObjectID, repository: HabitRepositoryProtocol) {
        self.habitId = habitId
        self.repository = repository
    }
    
    func makeCalendarModel(for selectedMonth: Date) -> HabitDetailsCalendarModel {
        
        let monthTitle = makeMonthTitle(from: selectedMonth)
        let yearTitle = makeYearTitle(from: selectedMonth)
        let days = makeMonthDays(for: selectedMonth)
        
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
    
    private func makeMonthDays(for selectedMonth: Date) -> [HabitDetailsCalendarDayCellModel] {
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
            repeating: HabitDetailsCalendarDayCellModel(dayNumber: nil, state: nil),
            count: leadingEmptyDays
        )
        
        days.append(contentsOf: emptyModels)
        
        for day in 1...numberOfDays {
            let model = HabitDetailsCalendarDayCellModel(
                dayNumber: day,
                state: .missed
            )
            days.append(model)
        }
        
        return days
    }
}
