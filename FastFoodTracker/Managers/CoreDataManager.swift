//
//  Manager.swift
//  EatTime
//
//  Created by Radion Vahromeev on 8/12/25.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FastFoodTracker")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error: \(error)")
            }
        }
        return container
    }()

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }

    func addEatTime(date: Date) {
        let eatTime = EatTime(context: context)
        eatTime.date = date
        saveContext()
    }

    func fetchEatTimes() -> [EatTime] {
        let request: NSFetchRequest<EatTime> = EatTime.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching: \(error)")
            return []
        }
    }
}
