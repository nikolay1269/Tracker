//
//  Date+String.swift
//  Tracker
//
//  Created by Nikolay on 28.11.2024.
//

import Foundation

extension Date {
    func stringFromDateForTrackersScreen() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        let string = dateFormatter.string(from: self)
        return string
    }
}
