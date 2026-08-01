//
//  TodayProgressState.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 17.07.2026.
//

import Foundation

struct TodayProgressState {
    let title: String
    let completedText: String
    let progress: Double
    let weekDays: [TodayProgressDayState]
}

struct TodayProgressDayState {
    let weekdayTitle: String
    let dayNumberText: String
    let progress: Double
    let isToday: Bool
    let isFuture: Bool
}
