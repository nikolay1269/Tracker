//
//  TrackerRecordStoreProtocol.swift
//  Tracker
//
//  Created by Nikolay on 31.01.2025.
//

import Foundation

protocol TrackerRecordStoreProtocol {
    func isTrackerCompetedForDate(tracker: Tracker, date: Date) -> Bool
    func addRecordForTracker(_ tracker: Tracker, date: Date)
    func removeRecordForTracker(_ tracker: Tracker, date: Date)
    func trackerCompletedCount(_ tracker: Tracker) -> Int
    func numberOfCompletedTrackers() -> Int
}
