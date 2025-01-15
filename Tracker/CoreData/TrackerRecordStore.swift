//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Nikolay on 31.12.2024.
//

import Foundation
import CoreData

protocol TrackerRecordStoreProtocol {
    func isTrackerCompetedForDate(tracker: Tracker, date: Date) -> Bool
    func addRecordForTracker(_ tracker: Tracker, date: Date)
    func removeRecordForTracker(_ tracker: Tracker, date: Date)
    func trackerCompletedCount(_ tracker: Tracker) -> Int
}

final class TrackerRecordStore {
    
    private var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }    
}

extension TrackerRecordStore: TrackerRecordStoreProtocol {

    func addRecordForTracker(_ tracker: Tracker, date: Date) {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        trackerRecordCoreData.id = UUID()
        trackerRecordCoreData.date = date
        trackerRecordCoreData.trackers = getTrackerCoreDataById(tracker.id)
        CoreDataManager.shared.saveContext()
    }
    
    func removeRecordForTracker(_ tracker: Tracker, date: Date) {
        let results = trackerRecordsForTracker(tracker)
        for result in results {
            if result.date?.scheduleComparison(date: date) == .orderedSame {
                context.delete(result)
                CoreDataManager.shared.saveContext()
                break
            }
        }
    }
    
    private func getTrackerCoreDataById(_ id: UUID) -> TrackerCoreData? {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "%K == %@", (\TrackerCoreData.id)._kvcKeyPathString!, id as NSUUID)
        do {
            let result = try context.fetch(fetchRequest).first
            return result
        } catch {
            print(error)
        }
        return nil
    }
    
    func isTrackerCompetedForDate(tracker: Tracker, date: Date) -> Bool {
        var filteredTrackerRecords: [TrackerRecordCoreData] = []
        let results = trackerRecordsForTracker(tracker)
        for result in results {
            if result.date?.scheduleComparison(date: date) == .orderedSame {
                filteredTrackerRecords.append(result)
            }
        }
        return filteredTrackerRecords.count > 0
    }
    
    func trackerCompletedCount(_ tracker: Tracker) -> Int {
        return trackerRecordsForTracker(tracker).count
    }
    
    private func trackerRecordsForTracker(_ tracker: Tracker) -> [TrackerRecordCoreData] {
        guard let trackerIdFieldName = (\TrackerRecordCoreData.trackers?.id)._kvcKeyPathString else {
            return []
        }
        
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        let predicate = NSPredicate(format: "%K == %@", trackerIdFieldName, tracker.id as NSUUID)
        fetchRequest.predicate = predicate
        if let results = try? context.fetch(fetchRequest) {
            return results
        } else {
            return []
        }
    }
}
