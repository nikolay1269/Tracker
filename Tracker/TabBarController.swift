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

        
        let trackersViewController = TrackersViewController()
        let navigationViewController = UINavigationController(rootViewController: trackersViewController)
        //navigationViewController.viewControllers = [trackersViewController]
        navigationViewController.navigationBar.barStyle = .black
        navigationViewController.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(named: "TrackersInactive"), selectedImage: UIImage(named: "TrackersActive"))
        
        let statisticsViewController = StatisticsViewController()
        statisticsViewController.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(named: "StatisticsInactive"), selectedImage: UIImage(named: "StatisticsActive"))
        
        self.viewControllers = [navigationViewController, statisticsViewController]
    }
}
