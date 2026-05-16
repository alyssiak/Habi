//
//  Repository.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 30.04.2026.
//

import Foundation
import CoreData

protocol HabitRepositoryProtocol {
    func fetchHabits() -> [Habit]
    func addHabit(title: String, emoji: String?, colorHex: String?)
    func updateHabit(_ habit: Habit, title: String, emoji: String?, colorHex: String?)
    func deleteHabit(_ habit: Habit)
    func toggleToday(for habitId: NSManagedObjectID)
    
    func toggleHabitRecord(_ habit: Habit, date: Date)
    func fetchRecords(for habit: Habit) -> [HabitRecord]
    func isHabitCompleted(_ habit: Habit, on date: Date) -> Bool
}


final class HabitRepository: HabitRepositoryProtocol {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // CRUD
    
    //read
    func fetchHabits() -> [Habit] {
        let request: NSFetchRequest<Habit> = Habit.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print(error)
            return []
        }
    }
    
    func addHabit(title: String, emoji: String?, colorHex: String?) {
        let habit = Habit(context: context)
        habit.id = UUID()
        habit.title = title
        habit.emoji = emoji ?? " "
        habit.colorHex = colorHex ?? "#FFFFFF"
        habit.createdAt = Date()
        habit.isArchived = false
        save()
    }
    
    func updateHabit(_ habit: Habit, title: String, emoji: String?, colorHex: String?) {
        habit.title = title
        habit.emoji = emoji ?? " "
        habit.colorHex = colorHex ?? "#FFFFFF"
        save()
    }
    
    func deleteHabit(_ habit: Habit) {
        context.delete(habit)
        save()
    }
    
    func toggleToday(for habitId: NSManagedObjectID) {
        do {
            guard let habit = try context.existingObject(with: habitId) as? Habit
            else {
                return
            }
            toggleHabitRecord(habit, date: Date())
        } catch {
            print(error)
        }
        
    }
    
    private func save() {
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
    
    //MARK: - HabitRecord
    func toggleHabitRecord(_ habit: Habit, date: Date) {
        let calendar = Calendar.current
        
        // берем начало текущего дня 00:00
        let startOfDay = calendar.startOfDay(for: date)
        
        // берем полночь следующего дня
        guard let nextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)
        else {
            return
        }
        
        let fetchRequest: NSFetchRequest<HabitRecord> = HabitRecord.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "habit == %@ AND date >= %@ AND date < %@",
                                    habit,
                                    startOfDay as NSDate,
                                    nextDay as NSDate)
        
        fetchRequest.fetchLimit = 1
        
        do {
            let records = try context.fetch(fetchRequest)
            let record = records.first
            
            if let record {
                record.isCompleted.toggle()
            } else {
                let record = HabitRecord(context: context)
                record.habit = habit
                record.isCompleted = true
                record.date = startOfDay
            }
            
            save()
        } catch {
            print(error)
        }
    }
    
    func fetchRecords(for habit: Habit) -> [HabitRecord] {
        return []
    }
    
    func isHabitCompleted(_ habit: Habit, on date: Date) -> Bool {
        return false
    }
}
