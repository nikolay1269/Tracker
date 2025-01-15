//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Nikolay on 31.12.2024.
//

import Foundation
import CoreData
import UIKit

enum TrackerCategoryStoreError: Error {
    case decodingKeyErrorInvalidId
    case decodingKeyErrorInvalidName
}

protocol TrackerCategoryStoreProtocol {
    var numberOfSections: Int { get }
    func numbersOfObjectsInSection(_ section: Int) -> Int
    func titleForSection(_ section: Int) -> String
    func addRecord(_ record: TrackerCategory) throws
    func object(at: IndexPath) throws -> Tracker?
    func getDefaultCategory() -> TrackerCategory?
    func setCurrentDate(date: Date)
    func setSearchText(text: String)
    func numberOfItems() -> Int
}

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdate()
}

final class TrackerCategoryStore: NSObject {
    
    // MARK: - Public Properties
    var currentDate: Date
    var searchText: String?
    
    // MARK: - Private Properties
    private var context: NSManagedObjectContext
    private weak var delegate: TrackerCategoryStoreDelegate?
    
    private lazy var fetchedResultController: NSFetchedResultsController<TrackerCategoryCoreData> = {
       
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(TrackerCategoryCoreData.name), ascending: true)]
        let fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultController.delegate = self
        try? fetchResultController.performFetch()
        return fetchResultController
    }()
    
    // MARK: - Initializers
    init(context: NSManagedObjectContext, date: Date, delegate: TrackerCategoryStoreDelegate) {
        self.context = context
        self.currentDate = date
        self.delegate = delegate
    }
}

// MARK: - TrackerCategoryStoreProtocol
extension TrackerCategoryStore: TrackerCategoryStoreProtocol {
    
    func setSearchText(text: String) {
        self.searchText = text
    }
    
    func numberOfItems() -> Int {
        guard let fetchObjects = fetchedResultController.fetchedObjects else {
            return 0
        }
        var result = 0
        for fetchObject in fetchObjects {
            let trackers = filteredTrackersForCategory(fetchObject)
            let numberOfTrackersForCategory = trackers.count
            result = result + numberOfTrackersForCategory
        }
        return result
    }
    
    func setCurrentDate(date: Date) {
        self.currentDate = date
    }

    func titleForSection(_ section: Int) -> String {
        guard fetchedResultController.fetchedObjects?.count ?? 0 > 0 else {
            return ""
        }
        
        if let trackerCategoryCoreData = fetchedResultController.fetchedObjects?[section] {
            let filteredTrackers = filteredTrackersForCategory(trackerCategoryCoreData)
            if filteredTrackers.count > 0 {
                return trackerCategoryCoreData.name ?? ""
            } else {
                return ""
            }
        } else {
            return ""
        }
    }
    
    func getDefaultCategory() -> TrackerCategory? {
        if let trackerCategoryCoreData = fetchedResultController.fetchedObjects?.first {
            let trackerCategory = try? trackerCategoryFromCoreDataObject(trackerCategoryCoreData)
            return trackerCategory
        }
        return nil
    }
    
    var numberOfSections: Int {
        fetchedResultController.sections?.count ?? 0
    }
    
    func numbersOfObjectsInSection(_ section: Int) -> Int {
        guard let objectsCount = fetchedResultController.fetchedObjects?.count,
              objectsCount > 0,
              let trackerCategoryCoreData: TrackerCategoryCoreData = fetchedResultController.fetchedObjects?[section] else {
            return 0
        }
        let filteredTrackers = filteredTrackersForCategory(trackerCategoryCoreData)
        return filteredTrackers.count
    }
    
    private func trackerCategoryFromCoreDataObject(_ categoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let name = categoryCoreData.name else {
            throw TrackerCategoryStoreError.decodingKeyErrorInvalidName
        }
        guard let id = categoryCoreData.categoryId else {
            throw TrackerCategoryStoreError.decodingKeyErrorInvalidId
        }
        let trackerCategory = TrackerCategory(id: id, name: name, trackers: [])
        return trackerCategory
    }
    
    private func weekDaysFromInt(_ weekDaysInt: Int16) -> Set<WeekDay> {
        var result = Set<WeekDay>()
        for weekDay in WeekDay.allCases {
            if weekDaysInt & weekDay.value > 0 {
                result.insert(weekDay)
            }
        }
        return result
    }
    
    private func isTrackerForWeekDay(_ weekDay: WeekDay, weekDayInt: Int16) -> Bool {
        return weekDayInt & weekDay.value > 0
    }
    
    func object(at: IndexPath) throws -> Tracker? {
        guard let trackerCategoryCoreData: TrackerCategoryCoreData = fetchedResultController.fetchedObjects?[at.section] else {
            fatalError()
        }
        let filteredTrackers = filteredTrackersForCategory(trackerCategoryCoreData)
        if filteredTrackers.count == 0 {
            return nil
        }
        let trackerCoreDataObject = filteredTrackers[at.row]
        guard let id = trackerCoreDataObject.id else {
            throw TrackerStoreError.decodingKeyErrorInvalidId
        }
        guard let name = trackerCoreDataObject.name else {
            throw TrackerStoreError.decodingKeyErrorInvalidName
        }
        guard let colorHex = trackerCoreDataObject.colorHex else {
            throw TrackerStoreError.decodingKeyErrorInvalidColor
        }
        guard let emoji = trackerCoreDataObject.emoji else {
            throw TrackerStoreError.decodingKeyErrorInvalidEmoji
        }
        let trackerObject = Tracker(id: id,
                                    name: name,
                                    color: UIColor.colorFromHex(hex: colorHex),
                                    emoji: emoji,
                                    schedule: weekDaysFromInt(trackerCoreDataObject.schedule))
        return trackerObject
    }
    
    private func filteredTrackersForCategory(_ category: TrackerCategoryCoreData) -> [TrackerCoreData] {
        
        guard let currentDayOfWeekInt = Calendar.current.dateComponents([.weekday], from: currentDate).weekday, let currentDayOfWeek = WeekDay(rawValue: currentDayOfWeekInt) else { return [] }
        let filteredTrackers: [TrackerCoreData] = category.trackers?.allObjects.filter({ tcd in
            let trackerCoreData = tcd as! TrackerCoreData
            let name = trackerCoreData.name?.lowercased() ?? ""
            let searchText = searchText?.lowercased() ?? ""
            return (isTrackerForWeekDay(currentDayOfWeek, weekDayInt: trackerCoreData.schedule) ||
            (trackerCoreData.schedule == 0 &&
             (trackerCoreData.records?.count == 0 || trackerCoreData.records?.filter({ record in
                let trackerRerordCoreData = record as! TrackerRecordCoreData
                return trackerRerordCoreData.date?.scheduleComparison(date: currentDate) == .orderedSame
            }).count ?? 0 > 0))) && (name.contains(searchText) || searchText.isEmpty)
        }) as! [TrackerCoreData]
        return filteredTrackers
    }
    
    func addRecord(_ record: TrackerCategory) throws {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        trackerCategoryCoreData.categoryId = record.id
        trackerCategoryCoreData.name = record.name
        CoreDataManager.shared.saveContext()
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        delegate?.didUpdate()
    }
}
