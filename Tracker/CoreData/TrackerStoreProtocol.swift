//
//  TrackerStoreProtocol.swift
//  Tracker
//
//  Created by Nikolay on 31.01.2025.
//

import Foundation

protocol TrackerStoreProtocol {
    func addRecord(_ record: Tracker, categoryId: UUID) throws
    func updateRecord(_ record: Tracker, categoryId: UUID) throws
    func deleteRecord(_ record: Tracker) throws
}
