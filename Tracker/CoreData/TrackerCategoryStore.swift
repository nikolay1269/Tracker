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
    func numberOfCategories() -> Int
    func allTrackerCategories() -> [TrackerCategory]
    func titleForSection(_ section: Int) -> String
    func category(at: IndexPath) -> TrackerCategory?
    func addRecord(_ record: TrackerCategory) throws
    func numbersOfFilteredTrackersInSection(_ section: Int) -> Int
    func filteredTracker(at: IndexPath) throws -> Tracker?
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
    init(context: NSManagedObjectContext, date: Date, delegate: TrackerCategoryStoreDelegate? = nil) {
        self.context = context
        self.currentDate = date
        self.delegate = delegate
    }
    
    // MARK: - Private Methods
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
    
    private func filteredTrackerCategoriesCoreData() -> [TrackerCategoryCoreData] {
        
        var result: [TrackerCategoryCoreData] = []
        guard let fethedObjects = fetchedResultController.fetchedObjects else {
            return []
        }
        
        for trackerCategoryCoreData in fethedObjects {
            let filteredTrackers = filteredTrackersForCategory(trackerCategoryCoreData)
            if filteredTrackers.count > 0 {
                result.append(trackerCategoryCoreData)
            }
        }
        return result
    }
    
    private func allTrackerCategoriesCoreData() -> [TrackerCategoryCoreData] {
        guard let objects = fetchedResultController.fetchedObjects else {
            return []
        }
        return objects
    }
    
    private func isTrackerForWeekDay(_ weekDay: WeekDay, weekDayInt: Int16) -> Bool {
        return weekDayInt & weekDay.value > 0
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
}

// MARK: - TrackerCategoryStoreProtocol
extension TrackerCategoryStore: TrackerCategoryStoreProtocol {
    
    var numberOfSections: Int {
        filteredTrackerCategoriesCoreData().count
    }
    
    func numberOfCategories() -> Int {
        return fetchedResultController.fetchedObjects?.count ?? 0
    }
    
    func allTrackerCategories() -> [TrackerCategory] {
        var result: [TrackerCategory] = []
        let trackerCategoriesCoreData = allTrackerCategoriesCoreData()
        for trackerCategoryCoreData in trackerCategoriesCoreData {
            do {
                try result.append(trackerCategoryFromCoreDataObject(trackerCategoryCoreData))
            } catch {
                print(error)
            }
        }
        return result
    }
    
    func titleForSection(_ section: Int) -> String {
        let filteredTrackerCategories = filteredTrackerCategoriesCoreData()
        return filteredTrackerCategories[section].name ?? ""
    }
    
    func category(at: IndexPath) -> TrackerCategory? {
        if let categoryCoreData = fetchedResultController.fetchedObjects?[at.row] {
            return try? trackerCategoryFromCoreDataObject(categoryCoreData)
        } else {
            return nil
        }
    }
    
    func addRecord(_ record: TrackerCategory) throws {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        trackerCategoryCoreData.categoryId = record.id
        trackerCategoryCoreData.name = record.name
        CoreDataManager.shared.saveContext()
    }
    
    func numbersOfFilteredTrackersInSection(_ section: Int) -> Int {
        let filteredTrackerCategies = filteredTrackerCategoriesCoreData()
        let trackerCategoryCoreData = filteredTrackerCategies[section]
        let filteredTrackers = filteredTrackersForCategory(trackerCategoryCoreData)
        return filteredTrackers.count
    }
    
    func filteredTracker(at: IndexPath) throws -> Tracker? {
        let filteredTrackerCategories = filteredTrackerCategoriesCoreData()
        let trackerCategoryCoreData = filteredTrackerCategories[at.section]
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
    
    func setCurrentDate(date: Date) {
        self.currentDate = date
    }
    
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
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        delegate?.didUpdate()
    }
}
