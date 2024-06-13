//
//  TabBarController.swift
//  Tracker
//
//  Created by Антон Павлов on 17.01.2024.
//

import UIKit

final class TabBarViewController: UITabBarController {
    
    // MARK: - Initialization
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        settingTabControllers()
        setupTabBarAppearance()
    }
    
    override func traitCollectionDidChange(
        _ previousTraitCollection: UITraitCollection?
    ) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(
            comparedTo: previousTraitCollection
        ) {
            setupTabBarAppearance()
        }
    }
    
    private func setupTabBarAppearance() {
        if traitCollection.userInterfaceStyle == .dark {
            tabBar.layer.borderColor = UIColor.black.cgColor
        } else {
            tabBar.layer.borderColor = UIColor.lightGray.cgColor
        }
        tabBar.layer.borderWidth = 1.0
        tabBar.clipsToBounds = true
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
    
    private func createNavigationController(
        rootViewController: UIViewController
    ) -> UINavigationController {
        let navigationController = UINavigationController(
            rootViewController: rootViewController
        )
        return navigationController
    }
}
