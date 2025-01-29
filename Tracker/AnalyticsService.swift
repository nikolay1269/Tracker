//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Nikolay on 29.01.2025.
//

import Foundation
import Foundation
import YandexMobileMetrica

enum ClickItem: String {
    case add_track
    case track
    case filter
    case edit
    case delete
}

enum Screen: String {
    case main = "Main"
}

final class AnalyticService {
    
    static let shared = AnalyticService()
    
    func sendOpenEvent(screen: Screen) {
        let params: [AnyHashable : Any] = ["screen": "\(screen.rawValue)"]
        YMMYandexMetrica.reportEvent("open", parameters: params, onFailure: { error in print("REPORT ERROR: %@", error.localizedDescription) })
    }
    
    func sendCloseEvent(screen: Screen) {
        let params: [AnyHashable : Any] = ["screen": "\(screen.rawValue)"]
        YMMYandexMetrica.reportEvent("close", parameters: params, onFailure: { error in print("REPORT ERROR: %@", error.localizedDescription) })
    }
    
    func sendClickEvent(screen: Screen, item: ClickItem) {
        let params: [AnyHashable : Any] = ["screen": "\(screen.rawValue)", "item" : "\(item.rawValue)"]
        YMMYandexMetrica.reportEvent("click", parameters: params, onFailure: { error in print("REPORT ERROR: %@", error.localizedDescription) })
    }
}
