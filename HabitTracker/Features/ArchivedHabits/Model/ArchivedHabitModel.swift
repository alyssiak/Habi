//
//  ArchivedHabitModel.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 24.06.2026.
//

import Foundation
import CoreData

struct ArchivedHabitModel {
    let id: NSManagedObjectID
    let emoji: String
    let title: String
    let descriptionText: String
    let colorHex: String
}
