//
//  TrackerStoreError.swift
//  Tracker
//
//  Created by Nikolay on 31.01.2025.
//

import Foundation

enum TrackerStoreError: Error {
    case decodingKeyErrorInvalidId
    case decodingKeyErrorInvalidName
    case decodingKeyErrorInvalidColor
    case decodingKeyErrorInvalidEmoji
    case decodingKeyErrorInvalidSchedule
    case decodingKeyErrorInvalidIsPinned
}
