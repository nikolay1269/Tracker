//
//  Tracker.swift
//  Tracker
//
//  Created by Nikolay on 04.12.2024.
//

import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: Set<WeekDay>
}
