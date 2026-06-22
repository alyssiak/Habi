//
//  HabitFormModel.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 22.06.2026.
//
import CoreData

struct HabitFormModel {
    let id: NSManagedObjectID
    let title: String
    let emoji: String?
    let colorHex: String?
}

extension HabitFormModel {
    init(cardModel: HabitCardModel) {
        self.id = cardModel.id
        self.title = cardModel.title
        self.emoji = cardModel.emoji
        self.colorHex = cardModel.colorHex
    }
}
