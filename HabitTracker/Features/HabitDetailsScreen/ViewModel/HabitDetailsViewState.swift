//
//  HabitDetailsViewState.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 22.06.2026.
//

struct HabitDetailsHeaderModel {
    let title: String
    let emoji: String
    let colorHex: String
}

struct HabitDetailsCalendarModel {
    let monthTitle: String
    let yearTitle: String
    let days: [HabitDetailsCalendarDayCellModel]
}

struct HabitDetailsStatsModel {
    let completedDays: Int
    let bestStreak: Int
    let currentStreak: Int
}

struct HabitDetailsViewState {
    let header: HabitDetailsHeaderModel
    let form: HabitFormModel
    let calendar: HabitDetailsCalendarModel
    let stats: HabitDetailsStatsModel
}
