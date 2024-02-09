//
//  ViewController.swift
//  Tracker
//
//  Created by Антон Павлов on 17.01.2024.
//

import UIKit

final class TrackerViewController: UIViewController {
    
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    
    private let search = UISearchController(searchResultsController: nil)
    
    private lazy var willTrackLabel: UILabel = {
        let trackLabel = UILabel()
        trackLabel.translatesAutoresizingMaskIntoConstraints = false
        trackLabel.text = "Что будем отслеживать?"
        trackLabel.font = UIFont.boldSystemFont(ofSize: 12)
        trackLabel.textColor = .ypBlackDay
        
        return trackLabel
    }()
    
    private lazy var imagesViewStub = {
        let imageView = UIImageView(image: UIImage(named: "error1"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private lazy var dateSetting: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.calendar.firstWeekday = 2
        datePicker.clipsToBounds = true
        
        let datePickerItem = UIBarButtonItem(customView: datePicker)
        navigationItem.rightBarButtonItem = datePickerItem
        
        return datePicker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurationView()
        addElements()
        layoutConstraint()
        settingNavigationBar()
        settingSearchController()
    }
    
    private func configurationView() {
        view.backgroundColor = .ypWhiteDay
    }
    
    private func addElements() {
        view.addSubview(willTrackLabel)
        view.addSubview(dateSetting)
        view.addSubview(imagesViewStub)
    }
    
    private func layoutConstraint() {
        NSLayoutConstraint.activate([
            willTrackLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            willTrackLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            imagesViewStub.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imagesViewStub.bottomAnchor.constraint(equalTo: willTrackLabel.topAnchor, constant: -8),
            imagesViewStub.heightAnchor.constraint(equalToConstant: 80),
            imagesViewStub.widthAnchor.constraint(equalToConstant: 80),
            
            dateSetting.widthAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    private func settingNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        title = "Трекеры"
        
        let addTrackerButton = UIButton(type: .custom)
        addTrackerButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        
        addTrackerButton.addTarget(self,
                                   action: #selector(addTrackerButtonTapped),
                                   for: .touchUpInside)
        
        let addTrackerButtonItem = UIBarButtonItem(customView: addTrackerButton)
        navigationItem.leftBarButtonItem = addTrackerButtonItem
        
        if let addTrakerImage = UIImage(named: "addTracker")?.withRenderingMode(.alwaysOriginal) {
            addTrackerButton.setImage(addTrakerImage, for: .normal)
        }
    }
    
    @objc private func addTrackerButtonTapped() {
        let creationHabbit = TrackerCreator()
        let creationHabbitNavigationController = UINavigationController(rootViewController: creationHabbit)
        present(creationHabbitNavigationController, animated: true, completion: nil)
    }
}

extension TrackerViewController: UISearchControllerDelegate, UISearchBarDelegate {
    
    private func settingSearchController() {
        search.delegate = self
        search.searchBar.delegate = self
        search.searchBar.placeholder = "Поиск"
        
        navigationItem.searchController = search
        navigationItem.hidesSearchBarWhenScrolling = false
    }
}
