//
//  TrackerCategoriesViewModel.swift
//  Tracker
//
//  Created by Nikolay on 21.01.2025.
//

import Foundation

final class TrackerCategoriesViewModel {
    
    // MARK: - Public Properties
    var trackerCategoryViewModelsBinding: Binding<[TrackerCategoryViewModel]>?
    
    // MARK: - Private Properties
    private lazy var trackerCategoryStore: TrackerCategoryStoreProtocol? = {
        let context = CoreDataManager.shared.context
        let trackerCategoryStore = TrackerCategoryStore(context: context, date: Date(), delegate: self)
        return trackerCategoryStore
    }()
    
    private(set) var trackerCategoryViewModels: [TrackerCategoryViewModel] = [] {
        didSet {
            trackerCategoryViewModelsBinding?(trackerCategoryViewModels)
        }
    }
    
    // MARK: - Public Methods
    func numberOfCategories() -> Int {
        return trackerCategoryStore?.numberOfCategories() ?? 0
    }
    
    func tracketCategoryViewModelAt(_ at: IndexPath) -> TrackerCategoryViewModel? {
        guard let category = trackerCategoryStore?.category(at: at) else {
            return nil
        }
        return TrackerCategoryViewModel(id: category.id, name: category.name, trackers: category.trackers)
    }
    
    func addTrackerCategoryTapped(name: String) {
        let newTrackerCategory = TrackerCategory(id: UUID(), name: name, trackers: [])
        do {
            try trackerCategoryStore?.addRecord(newTrackerCategory)
        } catch {
            print(error)
        }
    }
    
    // MARK: - Private Methods
    private func getTrackerCategoriesViewModelsFromStore() -> [TrackerCategoryViewModel] {
        guard let filteredCategories = trackerCategoryStore?.allTrackerCategories() else {
            return []
        }
        return filteredCategories.map {
            TrackerCategoryViewModel(id: $0.id, name: $0.name, trackers: $0.trackers)
        }
    }
}

extension TrackerCategoriesViewModel: TrackerCategoryStoreDelegate {
    
    func didUpdate() {
        trackerCategoryViewModels = getTrackerCategoriesViewModelsFromStore()
    }
}
