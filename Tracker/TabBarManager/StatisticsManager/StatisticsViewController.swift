//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Антон Павлов on 01.02.2024.
//

import UIKit

final class StatisticsViewController: UIViewController {
    
    private var completedTrackerCount: Int = 0
    
    // MARK: - UI Components
    private lazy var emptyStateImageView = {
        let image = UIImageView(image: UIImage(named: "error3"))
        image.contentMode = .scaleAspectFit
        
        return image
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = LocalizationHelper.localizedString("emptyStatisticText")
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        
        return label
    }()
    
    private lazy var analyticsController: AnalyticsController = {
        let view = AnalyticsController()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.configure(
            value: 0, description: LocalizationHelper.localizedString("completedTrackers")
        )
        return view
    }()
    
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
        view.backgroundColor = .ypWhite
        CoreDataStack.shared.trackerRecordStore.delegate = self 
        settingNavigationBar()
        addElemens()
        layoutConstraint()
        updateUI()
    }
    
    private func settingNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = LocalizationHelper.localizedString("statistic")
    }
    
    // MARK: - Setup Methods
    private func addElemens() {
        [emptyStateImageView,
         emptyStateLabel,
         analyticsController
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func layoutConstraint() {
        NSLayoutConstraint.activate([
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: +8),
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            emptyStateImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            analyticsController.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 77),
            analyticsController.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            analyticsController.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            analyticsController.heightAnchor.constraint(equalToConstant: 90)
        ])
    }
    
    private func updateUI() {
        completedTrackerCount = CoreDataStack.shared.trackerRecordStore.fetchCompletedTrackerCount()
        
        analyticsController.configure(
            value: completedTrackerCount,
            description: LocalizationHelper.localizedString("completedTrackers")
        )
        
        let isEmpty = completedTrackerCount == 0
        
        emptyStateLabel.isHidden = !isEmpty
        emptyStateImageView.isHidden = !isEmpty
        analyticsController.isHidden = isEmpty
    }
}

extension StatisticsViewController: TrackerRecordStoreDelegate {
    func trackerRecordStoreDidChange() {
        updateUI()
    }
}
