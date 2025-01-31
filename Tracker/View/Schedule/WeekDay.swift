//
//  WeekDay.swift
//  Tracker
//
//  Created by Nikolay on 31.01.2025.
//

import Foundation

enum WeekDay: Int, Codable, CaseIterable {
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    case sunday = 1
    
    var value: Int16 {
        return Int16(1 << self.rawValue)
    }
}
