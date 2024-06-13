//
//  TrackerCreator.swift
//  Tracker
//
//  Created by Антон Павлов on 09.02.2024.
//

import UIKit

final class TrackerCreator: UIViewController {
    
    // MARK: - Delegate
    weak var trackerViewController: TrackerViewController?
    weak var habitCreationDelegate: HabitCreationDelegate?
    
    // MARK: - Private Properties
    private lazy var creationLabel = CustomTitleLabel(
        text: LocalizationHelper.localizedString("trackerCreation")
    )
    
    private lazy var creationHabbitButton: CustomButton = {
        let button = CustomButton(
            title: LocalizationHelper.localizedString("habit")
        )
        button.addTarget(
            self,
            action: #selector(creationHabbitButtonTapped),
            for: .touchUpInside
        )
        
        return button
    }()
    
    private lazy var сreatingIrregularEvents: CustomButton = {
        let button = CustomButton(
            title:  LocalizationHelper.localizedString("irregularEvent")
        )
        button.addTarget(
            self, action: #selector(сreatingIrregularEventsTapped),
            for: .touchUpInside
        )
        
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        view.backgroundColor = .ypWhiteDay
        addElements()
        layoutConstraint()
    }
    
    // MARK: - Setup View
    private func addElements() {
        [creationLabel,
         creationHabbitButton,
         сreatingIrregularEvents
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func layoutConstraint() {
        NSLayoutConstraint.activate([
            creationLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            creationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            creationHabbitButton.topAnchor.constraint(equalTo: creationLabel.bottomAnchor, constant: 295),
            creationHabbitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            creationHabbitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            creationHabbitButton.heightAnchor.constraint(equalToConstant: 60),
            сreatingIrregularEvents.heightAnchor.constraint(equalToConstant: 60),
            
            сreatingIrregularEvents.topAnchor.constraint(equalTo: creationHabbitButton.bottomAnchor, constant: 16),
            сreatingIrregularEvents.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            сreatingIrregularEvents.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // MARK: - Action
    @objc private func settingCreateHabbitButtonTapped(isHabit: Bool) {
        let createHabbitVC = HabitCreation(isHabit: isHabit)
        createHabbitVC.habitCreationDelegate = trackerViewController
        createHabbitVC.modalPresentationStyle = .pageSheet
        present(createHabbitVC, animated: true, completion: nil)
    }
    
    @objc private func creationHabbitButtonTapped() {
        settingCreateHabbitButtonTapped(isHabit: true)
    }
    
    @objc private func сreatingIrregularEventsTapped() {
        settingCreateHabbitButtonTapped(isHabit: false)
    }
}
