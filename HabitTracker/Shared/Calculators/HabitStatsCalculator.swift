//
//  HabitStatsCalculator.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 22.06.2026.
//

import Foundation
import CoreData

struct HabitStats {
    let completedDays: Int
    let currentStreak: Int
    let bestStreak: Int
}

protocol HabitStatsCalculating {
    func makeStats(from records: [HabitRecord]) -> HabitStats
}

struct HabitStatsCalculator: HabitStatsCalculating {
    func makeStats(from records: [HabitRecord]) -> HabitStats {
        let completedDates = completedStartOfDay(from: records)
        return makeStats(fromCompletedDates: completedDates)
    }
    
    func makeStats(fromCompletedDates dates: [Date], today: Date = Date()) -> HabitStats {
        let completedDates = Array(Set(dates.map { Calendar.current.startOfDay(for: $0)})).sorted()
        
        return HabitStats(
            completedDays: completedDates.count,
            currentStreak: calculateCurrentStreak(from: completedDates, today: today),
            bestStreak: calculateBestStreak(from: completedDates)
        )
    }
    
    private func completedStartOfDay(from records: [HabitRecord]) -> [Date] {
        let calendar = Calendar.current
        
        let completedDates = records
            .filter { $0.isCompleted }
            .compactMap { $0.date }
            .map { calendar.startOfDay(for: $0) }
        
        return Array(Set(completedDates)).sorted()
    }
    
    //MARK: - Helpers
    private func calculateCurrentStreak(from completedDates: [Date], today: Date) -> Int {
        let calendar = Calendar.current
        let completedSet = Set(completedDates)
        
        var streak = 0
        var date = calendar.startOfDay(for: today)
        
        if !completedSet.contains(date),
           let yesterday = calendar.date(byAdding: .day, value: -1, to: date) {
            date = yesterday
        }
        
        while completedSet.contains(date) {
            streak += 1
            
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: date) else {
                break
            }
            
            date = previousDay
        }
        return streak
    }
    
    private func calculateBestStreak(from completedDates: [Date]) -> Int {
        let calendar = Calendar.current
        
        guard !completedDates.isEmpty else {
            return 0
        }
        
        var currentStreak = 1
        var bestStreak = 1
        
        for index in 1..<completedDates.count {
            let previousDate = completedDates[index - 1]
            let currentDate = completedDates[index]
            
            let daysBetween = calendar.dateComponents(
                [.day],
                from: previousDate,
                to: currentDate
            ).day
            
            if daysBetween == 1 {
                currentStreak += 1
            } else {
                currentStreak = 1
            }
            
            bestStreak = max(bestStreak, currentStreak)
        }
        return bestStreak
    }
}
