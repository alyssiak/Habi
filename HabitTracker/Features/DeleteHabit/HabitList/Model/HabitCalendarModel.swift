//
//  HabitCalendarModels.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 04.05.2026.
//

import Foundation

struct HabitCalendarDay {
    let date: Date
    let state: HabitCalendarDayState
}

enum HabitCalendarDayState {
    case future
    case completed
    case missed
}
