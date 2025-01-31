//
//  TrackerStore.swift
//  Tracker
//
//  Created by Nikolay on 31.12.2024.
//

import Foundation
import CoreData
import UIKit

final class TrackerStore: NSObject {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
}

extension TrackerStore: TrackerStoreProtocol {
    
    func addRecord(_ record: Tracker, categoryId: UUID) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = record.id
        trackerCoreData.name = record.name
        trackerCoreData.colorHex = UIColor.hexFromColor(color: record.color)
        trackerCoreData.emoji = record.emoji
        trackerCoreData.schedule = intFromWeekDays(record.schedule)
        let trackerCategoryCoreData = findCategoryById(categoryId)
        trackerCoreData.isPinned = record.isPinned
        trackerCoreData.category = trackerCategoryCoreData
        trackerCategoryCoreData?.addToTrackers(trackerCoreData)
        CoreDataManager.shared.saveContext()
    }
    
    func updateRecord(_ record: Tracker, categoryId: UUID) throws {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "%K == %@", (\TrackerCoreData.id)._kvcKeyPathString!, record.id as CVarArg)
        do {
            let updatedTracker = try context.fetch(fetchRequest).first
            updatedTracker?.name = record.name
            updatedTracker?.emoji = record.emoji
            updatedTracker?.colorHex = UIColor.hexFromColor(color: record.color)
            updatedTracker?.schedule = intFromWeekDays(record.schedule)
            let category = findCategoryById(categoryId)
            updatedTracker?.category = category
            updatedTracker?.isPinned = record.isPinned
            CoreDataManager.shared.saveContext()
        } catch {
            print(error)
        }
    }
    
    func deleteRecord(_ record: Tracker) throws {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "%K == %@", (\TrackerCoreData.id)._kvcKeyPathString!, record.id as CVarArg)
        do {
            if let deletedTracker = try context.fetch(fetchRequest).first {
                context.delete(deletedTracker)
                CoreDataManager.shared.saveContext()
            }
        } catch {
            print(error)
        }
    }
    
    private func findCategoryById(_ categoryId: UUID) -> TrackerCategoryCoreData? {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.categoryId), categoryId.uuidString)
        do {
            let filteredCategory = try context.fetch(fetchRequest).first
            return filteredCategory
        } catch {
            print(error)
        }
        return nil
    }
    
    func intFromWeekDays(_ weekDays: Set<WeekDay>) -> Int16 {
        var result: Int16 = 0x0
        for weekDay in weekDays {
            result = result ^ weekDay.value
        }
        return result
    }
}
