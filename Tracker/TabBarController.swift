//
//  TabBarController.swift
//  Tracker
//
//  Created by Nikolay on 30.11.2024.
//

import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = Colors.shared.backgroundColor
        appearance.shadowColor = Colors.shared.tabBarTopBorderColor
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        } else {
            view.backgroundColor = Colors.shared.backgroundColor
        }
        let trackersViewController = TrackersViewController()
        let navigationViewController = UINavigationController(rootViewController: trackersViewController)
        navigationViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("Trackers", comment: "Title of tab item"), image: UIImage(named: "TrackersInactive"), selectedImage: UIImage(named: "TrackersActive"))
        
        let statisticsViewController = StatisticsViewController()
        statisticsViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("Statistics", comment: "Title of tab bar item"), image: UIImage(named: "StatisticsInactive"), selectedImage: UIImage(named: "StatisticsActive"))
        
        self.viewControllers = [navigationViewController, statisticsViewController]
    }
}
