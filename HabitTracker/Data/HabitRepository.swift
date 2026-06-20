//
//  Repository.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 30.04.2026.
//

import Foundation
import CoreData
import Combine

protocol HabitRepositoryProtocol {
    var changesPublisher: AnyPublisher<Void, Never> { get }
    func fetchHabits() -> [Habit]
    func addHabit(title: String, emoji: String?, colorHex: String?)
    func updateHabit(_ habit: Habit, title: String, emoji: String?, colorHex: String?)
    func deleteHabit(_ habit: Habit)
    func restoreHabit(for habitId: NSManagedObjectID)
    func toggleToday(for habitId: NSManagedObjectID)

    func toggleHabitRecord(_ habit: Habit, date: Date)
    func fetchRecords(for habit: Habit) -> [HabitRecord]
    func isHabitCompleted(_ habit: Habit, on date: Date) -> Bool
    
    func fetchRecords(for habitId: NSManagedObjectID) -> [HabitRecord]
    func toggleHabitRecord(for habitId: NSManagedObjectID, date: Date)
}


final class HabitRepository: HabitRepositoryProtocol {
    private let context: NSManagedObjectContext
    private let changesSubject = PassthroughSubject<Void, Never>()
    
    var changesPublisher: AnyPublisher<Void, Never> {
        changesSubject.eraseToAnyPublisher()
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    private func save() {
        do {
            try context.save()
            changesSubject.send()
        } catch {
            print(error)
        }
    }
    
    func fetchHabits() -> [Habit] {
        let request: NSFetchRequest<Habit> = Habit.fetchRequest()
        request.predicate = NSPredicate(format: "isArchived == NO OR isArchived == nil")
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
        habit.isArchived = true
        save()
    }

    func restoreHabit(for habitId: NSManagedObjectID) {
        do {
            guard let habit = try context.existingObject(with: habitId) as? Habit else {
                return
            }

            habit.isArchived = false
            save()
        } catch {
            print(error)
        }
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

    //MARK: - HabitRecord
    func toggleHabitRecord(_ habit: Habit, date: Date) {
        let calendar = Calendar.current

        // берем начало текущего дня 00:00
        let startOfDay = calendar.startOfDay(for: date)

        // берем полночь следующего дня
        guard let nextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return
        }

        let fetchRequest: NSFetchRequest<HabitRecord> = HabitRecord.fetchRequest()

        fetchRequest.predicate = NSPredicate(
            format: "habit == %@ AND date >= %@ AND date < %@",
            habit,
            startOfDay as NSDate,
            nextDay as NSDate
        )

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
        let request: NSFetchRequest<HabitRecord> = HabitRecord.fetchRequest()
        request.predicate = NSPredicate(format: "habit == %@", habit)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]

        do {
            return try context.fetch(request)
        } catch {
            print(error)
            return []
        }
    }

    func isHabitCompleted(_ habit: Habit, on date: Date) -> Bool {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let nextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return false
        }

        let fetchRequest: NSFetchRequest<HabitRecord> = HabitRecord.fetchRequest()

        fetchRequest.predicate = NSPredicate(
            format: "habit == %@ AND date >= %@ AND date < %@ AND isCompleted == YES",
            habit,
            startOfDay as NSDate,
            nextDay as NSDate
        )

        fetchRequest.fetchLimit = 1

        do {
            return try context.count(for: fetchRequest) > 0
        } catch {
            print(error)
            return false
        }
    }
    
    func fetchRecords(for habitId: NSManagedObjectID) -> [HabitRecord] {
        do {
            guard let habit = try context.existingObject(with: habitId) as? Habit else {
                return []
            }
            
            return fetchRecords(for: habit)
        } catch {
            print(error)
            return []
        }
    }
    
    func toggleHabitRecord(for habitId: NSManagedObjectID, date: Date) {
        do {
            guard let habit = try context.existingObject(with: habitId) as? Habit else {
                return
            }
            
            toggleHabitRecord(habit, date: date)
        } catch {
            print(error)
        }
    }
}
