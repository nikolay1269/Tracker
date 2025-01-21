//
//  TrackerCategoryViewModel.swift
//  Tracker
//
//  Created by Nikolay on 21.01.2025.
//

import Foundation

final class TrackerCategoryViewModel {
    let id: UUID
    let name: String
    let trackers: [Tracker]
    
    init(id: UUID, name: String, trackers: [Tracker]) {
        self.id = id
        self.name = name
        self.trackers = trackers
    }
    
    var nameBinding: Binding<String>? {
        didSet {
            nameBinding?(name)
        }
    }
}
