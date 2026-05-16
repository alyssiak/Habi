//
//  CoreDataService.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 30.04.2026.
//

import Foundation
import CoreData

final class CoreDataService {    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "HabitTracker")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    // вычисляемое свойство
    var context: NSManagedObjectContext {
        return container.viewContext
    }

    // MARK: - Core Data Saving support

    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
