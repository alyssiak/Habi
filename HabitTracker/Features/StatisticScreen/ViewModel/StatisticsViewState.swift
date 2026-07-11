//
//  StatisticsViewState.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 10.07.2026.
//

import Foundation

enum StatisticsPeriod {
    case weekly
    case monthly
    
    var title: String {
        switch self {
           case .weekly:
               return "Weekly"
           case .monthly:
               return "Monthly"
           }
    }
}

struct StatisticsViewState {
    let selectedPeriod: StatisticsPeriod
    let title: String
    let subtitle: String
    let overallProgress: Double
    let overallPercentText: String
    let habitProgressItems: [HabitProgressItem]
    let monthDays: [MonthProgressDay]
    let selectedMonthText: String?
    let canShowNextMonth: Bool
    let topHabitProgressItems: [TopHabitProgressItem]
}

struct HabitProgressItem {
    let title: String
    let colorHex: String?
    let completedCount: Int
    let totalCount: Int
    let progress: Double
    let progressText: String
    let completedText: String
    let streak: Int
    let days: [HabitProgressDay]
}

struct HabitProgressDay {
    let title: String
    let isCompleted: Bool
    let isFuture: Bool
}

struct MonthProgressDay {
    let title: String
    let progress: Double
    let isFuture: Bool
}

struct TopHabitProgressItem {
    let title: String
    let colorHex: String?
    let progress: Double
    let progressText: String
    let completedText: String
}
