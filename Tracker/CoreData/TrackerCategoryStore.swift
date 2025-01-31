//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Nikolay on 31.12.2024.
//

import Foundation
import CoreData
import UIKit

final class TrackerCategoryStore: NSObject {
    
    // MARK: - Public Properties
    var currentDate: Date
    var searchText: String?
    var currentFilter = TrackerFilter.all
    
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
    
    private func filteredTrackerCategoriesCoreData(filterPinned: Bool = true) -> [TrackerCategoryCoreData] {
        
        var result: [TrackerCategoryCoreData] = []
        guard let fethedObjects = fetchedResultController.fetchedObjects else {
            return []
        }
        
        for trackerCategoryCoreData in fethedObjects {
            let filteredTrackers = filteredTrackersForCategory(trackerCategoryCoreData, filterPinned: filterPinned, filter: currentFilter, searchText: searchText)
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
    
    private func filteredTrackersForCategory(_ category: TrackerCategoryCoreData, filterPinned: Bool = true, filter: TrackerFilter, searchText: String?) -> [TrackerCoreData] {
        
        guard let currentDayOfWeekInt = Calendar.current.dateComponents([.weekday], from: currentDate).weekday, let currentDayOfWeek = WeekDay(rawValue: currentDayOfWeekInt) else { return [] }
        var filteredTrackers: [TrackerCoreData] = category.trackers?.allObjects.filter({ tcd in
            let trackerCoreData = tcd as? TrackerCoreData
            let name = trackerCoreData?.name?.lowercased() ?? ""
            let searchText = searchText?.lowercased() ?? ""
            return (isTrackerForWeekDay(currentDayOfWeek, weekDayInt: trackerCoreData?.schedule ?? 0) ||
                    (trackerCoreData?.schedule == 0 &&
                     (!isTrackerCompeleted(trackerCoreData) || trackerCoreData?.records?.filter({ record in
                let trackerRerordCoreData = record as? TrackerRecordCoreData
                return trackerRerordCoreData?.date?.scheduleComparison(date: currentDate) == .orderedSame
            }).count ?? 0 > 0))) &&
            (name.contains(searchText) || searchText.isEmpty) &&
            !(trackerCoreData?.isPinned ?? false && filterPinned) &&
            (isTrackerCompeleted(trackerCoreData) || filter != .completed) &&
            (!isTrackerCompeleted(trackerCoreData) || filter != .notcompleted)
        }) as? [TrackerCoreData] ?? []
        filteredTrackers.sort { tc1, tc2 in return tc1.name ?? "" < tc2.name ?? "" }
        return filteredTrackers
    }
    
    private func isTrackerCompeleted(_ trackerCoreData: TrackerCoreData?) -> Bool {
        return trackerCoreData?.records?.count ?? 0 > 0
    }
}

// MARK: - TrackerCategoryStoreProtocol
extension TrackerCategoryStore: TrackerCategoryStoreProtocol {
    
    var numberOfSections: Int {
        filteredTrackerCategoriesCoreData().count + (pinnedTrackersCoreData().count > 0 ? 1 : 0)
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
        if pinnedTrackersCoreData().count > 0 {
            if section == 0 {
                return "Закрепленные"
            } else {
                return filteredTrackerCategories[section - 1].name ?? ""
            }
        } else {
            return filteredTrackerCategories[section].name ?? ""
        }
    }
    
    func category(at: IndexPath) -> TrackerCategory? {
        if let categoryCoreData = fetchedResultController.fetchedObjects?[at.row] {
            return try? trackerCategoryFromCoreDataObject(categoryCoreData)
        } else {
            return nil
        }
    }
    
    func filteredCategory(at: IndexPath) -> TrackerCategory? {
        let pinnedTrackers = pinnedTrackersCoreData()
        let filteredCategories = filteredTrackerCategoriesCoreData()
        var categoryCoreData: TrackerCategoryCoreData
        if pinnedTrackers.count > 0 {
            if at.section == 0 {
                let trackerCoreDataObject = pinnedTrackers[at.row]
                if let category = trackerCoreDataObject.category {
                    return try? trackerCategoryFromCoreDataObject(category)
                } else {
                    return nil
                }
            } else {
                categoryCoreData = filteredCategories[at.section - 1]
            }
        } else {
            categoryCoreData = filteredCategories[at.section]
        }
        return try? trackerCategoryFromCoreDataObject(categoryCoreData)
    }
    
    func addRecord(_ record: TrackerCategory) throws {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        trackerCategoryCoreData.categoryId = record.id
        trackerCategoryCoreData.name = record.name
        CoreDataManager.shared.saveContext()
    }
    
    func numbersOfFilteredTrackersInSection(_ section: Int) -> Int {
        let pinnedTrackers = pinnedTrackersCoreData()
        let filteredTrackerCategies = filteredTrackerCategoriesCoreData()
        if pinnedTrackers.count > 0 {
            if section == 0 {
                return pinnedTrackers.count
            } else {
                let trackerCategoryCoreData = filteredTrackerCategies[section - 1]
                let filteredTrackers = filteredTrackersForCategory(trackerCategoryCoreData, filter: currentFilter, searchText: searchText)
                return filteredTrackers.count
            }
        } else {
            let trackerCategoryCoreData = filteredTrackerCategies[section]
            let filteredTrackers = filteredTrackersForCategory(trackerCategoryCoreData, filter: currentFilter, searchText: searchText)
            return filteredTrackers.count
        }
    }
    
    func filteredTracker(at: IndexPath) throws -> Tracker? {
        let pinnedTrackers = pinnedTrackersCoreData()
        let filteredTrackerCategories = filteredTrackerCategoriesCoreData()
        var trackerCategoryCoreData: TrackerCategoryCoreData
        var trackerCoreDataObject: TrackerCoreData
        if pinnedTrackers.count > 0 {
            if at.section == 0 {
                trackerCoreDataObject = pinnedTrackers[at.row]
            } else {
                trackerCategoryCoreData = filteredTrackerCategories[at.section - 1]
                let filteredTrackers = filteredTrackersForCategory(trackerCategoryCoreData, filter: currentFilter, searchText: searchText)
                if filteredTrackers.count == 0 { return nil }
                trackerCoreDataObject = filteredTrackers[at.row]
            }
        } else {
            trackerCategoryCoreData = filteredTrackerCategories[at.section]
            let filteredTrackers = filteredTrackersForCategory(trackerCategoryCoreData, filter: currentFilter, searchText: searchText)
            if filteredTrackers.count == 0 { return nil }
            trackerCoreDataObject = filteredTrackers[at.row]
        }
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
        let weekDaysInt = weekDaysFromInt(trackerCoreDataObject.schedule)
        let trackerObject = Tracker(id: id,
                                    name: name,
                                    color: UIColor.colorFromHex(hex: colorHex),
                                    emoji: emoji,
                                    schedule: weekDaysInt,
                                    isPinned: trackerCoreDataObject.isPinned)
        return trackerObject
    }
    
    func setCurrentDate(date: Date) {
        self.currentDate = date
    }
    
    func setSearchText(text: String) {
        self.searchText = text
    }
    
    func setCurrentFilter(filter: TrackerFilter) {
        currentFilter = filter
    }
    
    func numberOfItems(filter: TrackerFilter, searchText: String?) -> Int {
        guard let fetchObjects = fetchedResultController.fetchedObjects else {
            return 0
        }
        var result = 0
        for fetchObject in fetchObjects {
            let trackers = filteredTrackersForCategory(fetchObject, filterPinned: false, filter: filter, searchText: searchText)
            let numberOfTrackersForCategory = trackers.count
            result = result + numberOfTrackersForCategory
        }
        return result
    }
    
    func pinnedTrackersCoreData() -> [TrackerCoreData] {
        var result: [TrackerCoreData] = []
        let filteredTrackersCategoriesCoreData = filteredTrackerCategoriesCoreData(filterPinned: false)
        for category in filteredTrackersCategoriesCoreData {
            let filteredTrackers = filteredTrackersForCategory(category, filterPinned: false, filter: currentFilter, searchText: searchText)
            let pinnedTrackers = filteredTrackers.filter( { $0.isPinned } )
            for pinnedTracker in pinnedTrackers {
                result.append(pinnedTracker)
            }
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
