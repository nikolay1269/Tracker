//
//  TrackerCategoryCoreData+CoreDataProperties.swift
//  Tracker
//
//  Created by Nikolay on 10.01.2025.
//
//

import Foundation
import CoreData


extension TrackerCategoryCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerCategoryCoreData> {
        return NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
    }

    @NSManaged public var categoryId: UUID?
    @NSManaged public var name: String?
    //@NSManaged public var trackerId: UUID?
    @NSManaged public var trackers: NSSet?

}

// MARK: Generated accessors for trackers
extension TrackerCategoryCoreData {

    @objc(addTrackersObject:)
    @NSManaged public func addToTrackers(_ value: TrackerCoreData)

    @objc(removeTrackersObject:)
    @NSManaged public func removeFromTrackers(_ value: TrackerCoreData)

    @objc(addTrackers:)
    @NSManaged public func addToTrackers(_ values: NSSet)

    @objc(removeTrackers:)
    @NSManaged public func removeFromTrackers(_ values: NSSet)

}

extension TrackerCategoryCoreData : Identifiable {

}
