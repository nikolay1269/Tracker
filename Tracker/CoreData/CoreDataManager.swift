//
//  CoreDataManager.swift
//  Tracker
//
//  Created by Nikolay on 15.01.2025.
//

import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()
    let persistentContainer: NSPersistentContainer
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "Tracker")
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                print(error)
            }
        }
    }
    
    func saveContext() {
        do {
            try context.save()
        }
        catch {
            context.rollback()
            print(error)
        }
    }
}
