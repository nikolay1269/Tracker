//
//  TrackerStore.swift
//  Tracker
//
//  Created by Nikolay on 31.12.2024.
//

import Foundation
import CoreData
import UIKit

enum TrackerStoreError: Error {
    case decodingKeyErrorInvalidId
    case decodingKeyErrorInvalidName
    case decodingKeyErrorInvalidColor
    case decodingKeyErrorInvalidEmoji
    case decodingKeyErrorInvalidSchedule
}

protocol TrackerStoreProtocol {
    func addRecord(_ record: Tracker, categoryId: UUID) throws
}

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
        trackerCoreData.category = trackerCategoryCoreData
        trackerCategoryCoreData?.addToTrackers(trackerCoreData)
        do {
            try context.save()
        } catch let error {
            print(error)
            context.rollback()
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
