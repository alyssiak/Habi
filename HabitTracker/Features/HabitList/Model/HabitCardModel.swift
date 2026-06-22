//
//  HabitCardModel.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 05.05.2026.
//

import Foundation
import CoreData

struct HabitCardModel {
    let id: NSManagedObjectID
    let emoji: String?
    let colorHex: String?
    let descriptionText: String?
    let title: String
    let isDoneToday: Bool
    let days: [HabitCalendarDay]
    let streak: Int
    let completedDays: Int
    let totalDays: Int
    
    var shouldShowStreak: Bool {
        streak >= 5
    }
}
