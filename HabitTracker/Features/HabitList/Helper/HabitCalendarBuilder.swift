//
//  HabitCalendarBuilder.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 26.06.2026.
//

import Foundation

protocol HabitCalendarBuilding {
    func buildDays(
        createdAt: Date?,
        completedDates: [Date],
        today: Date
        ) -> [HabitCalendarDay]
    
    func isCompletedToday(
        completedDates: [Date],
        today: Date
    ) -> Bool
}

struct HabitCalendarBuilder: HabitCalendarBuilding {
    func buildDays(
        createdAt: Date?,
        completedDates: [Date],
        today: Date
    ) -> [HabitCalendarDay] {
        guard let createdAt else { return [] }
        
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: createdAt)
        let today = calendar.startOfDay(for: today)
        
        let totalDaysPassed = calendar.dateComponents(
            [.day],
            from: startDate,
            to: today
        ).day ?? 0
        
        let currentBlockIndex = totalDaysPassed / 30
        
        guard let blockStartDate = calendar.date(
            byAdding: .day,
            value: currentBlockIndex * 30,
            to: startDate
        ) else {
            return []
        }
        
        return (0..<30).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: blockStartDate) else {
                return nil
            }
            
            let state: HabitCalendarDayState
            
            if date > today {
                state = .future
            } else if hasCompletedRecord(on: date, completedDates: completedDates) {
                state = .completed
            } else {
                state = .missed
            }
            
            return HabitCalendarDay(date: date, state: state)
        }
    }
    
    func isCompletedToday(
        completedDates: [Date],
        today: Date = Date()
    ) -> Bool {
        hasCompletedRecord(on: today, completedDates: completedDates)
    }
    
    private func hasCompletedRecord(
        on date: Date,
        completedDates: [Date]
    ) -> Bool {
        let calendar = Calendar.current
        return completedDates.contains { completedDates in
            calendar.isDate(completedDates, inSameDayAs: date)
        }
    }
}
