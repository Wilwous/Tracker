//
//  TabBarController.swift
//  Tracker
//
//  Created by Антон Павлов on 17.01.2024.
//

import UIKit

final class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingTabControllers()
        settingDeviderLine()
    }
    
    private func settingTabControllers() {
        let trackerVC = TrackerViewController()
        let statisticsVC = StatisticsViewController()
        
        trackerVC.tabBarItem = UITabBarItem(
            title: LocalizationHelper.localizedString("trackers"),
            image: UIImage(named: "trackersIcon"),
            selectedImage: UIImage(named: "trackersIcon")
        )
        
        statisticsVC.tabBarItem = UITabBarItem(
            title: LocalizationHelper.localizedString("statistic"),
            image: UIImage(named: "statsIcon"),
            selectedImage: UIImage(named: "statsIcon")
        )
        
        viewControllers = [
            createNavigationController(rootViewController: trackerVC),
            createNavigationController(rootViewController: statisticsVC)
        ]
    }
    
    private func createNavigationController(rootViewController: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        return navigationController
    }
    
    private func settingDeviderLine() {
        tabBar.layer.borderColor = UIColor.ypGray.cgColor
        tabBar.layer.borderWidth = 1.0
        tabBar.clipsToBounds = true
    }
}
