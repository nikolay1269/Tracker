//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Nikolay on 29.01.2025.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {

    func testMainScreenLightTheme() {
        let vc = TabBarController()
        assertSnapshots(of: vc, as: [.image(traits: .init(userInterfaceStyle: .light))])
    }
    
    func testMainScreenDarkTheme() {
        let vc = TabBarController()
        assertSnapshots(of: vc, as: [.image(traits: .init(userInterfaceStyle: .dark))])
    }
    
    func testMainScreenForCurrentDate() {
        let tabBarViewController = TabBarController()
        guard let navigationViewController = tabBarViewController.viewControllers?[0] as? UINavigationController,
        let trackersViewController = navigationViewController.viewControllers.first as? TrackersViewController else {
            return
        }
        trackersViewController.currentDate = Date()
        trackersViewController.handleCurrentDate()
        
        assertSnapshots(of: tabBarViewController, as: [.image])
    }
}
