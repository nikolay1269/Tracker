//
//  TrackerCategoryStoreProtocol.swift
//  Tracker
//
//  Created by Nikolay on 31.01.2025.
//

import Foundation

protocol TrackerCategoryStoreProtocol {
    var numberOfSections: Int { get }
    func numberOfCategories() -> Int
    func allTrackerCategories() -> [TrackerCategory]
    func titleForSection(_ section: Int) -> String
    func category(at: IndexPath) -> TrackerCategory?
    func filteredCategory(at: IndexPath) -> TrackerCategory?
    func addRecord(_ record: TrackerCategory) throws
    func numbersOfFilteredTrackersInSection(_ section: Int) -> Int
    func filteredTracker(at: IndexPath) throws -> Tracker?
    func setCurrentDate(date: Date)
    func setSearchText(text: String)
    func setCurrentFilter(filter: TrackerFilter)
    func numberOfItems(filter: TrackerFilter, searchText: String?) -> Int
}
