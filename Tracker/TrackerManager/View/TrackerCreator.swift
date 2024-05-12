//
//  TrackerCreator.swift
//  Tracker
//
//  Created by Антон Павлов on 09.02.2024.
//

import UIKit

final class TrackerCreator: UIViewController {
    
    // MARK: - Private Properties
    private lazy var creationLabel: UILabel = {
        let creation = UILabel()
        creation.text = "Создание трекера"
        creation.textColor = .ypBlackDay
        creation.font = .systemFont(ofSize: 16)
        creation.translatesAutoresizingMaskIntoConstraints = false
        
        return creation
    }()
    
    private lazy var creationHabbitButton: UIButton = {
        let habbitButton = UIButton()
        habbitButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        habbitButton.setTitle("Привычка", for: .normal)
        habbitButton.setTitleColor(.ypWhiteDay, for: .normal)
        habbitButton.layer.cornerRadius = 16
        habbitButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        habbitButton.backgroundColor = .ypBlackDay
        habbitButton.translatesAutoresizingMaskIntoConstraints = false
        
        habbitButton.addTarget(self,
                               action: #selector(settingCreateHabbitButtonTapped),
                               for: .touchUpInside)
        
        return habbitButton
    }()
    
    private lazy var сreatingIrregularEvents: UIButton = {
        let irregularEvents = UIButton()
        irregularEvents.titleLabel?.font = .boldSystemFont(ofSize: 16)
        irregularEvents.setTitle("Нерегулярное событие", for: .normal)
        irregularEvents.setTitleColor(.ypWhiteDay, for: .normal)
        irregularEvents.layer.cornerRadius = 16
        irregularEvents.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        irregularEvents.backgroundColor = .ypBlackDay
        irregularEvents.translatesAutoresizingMaskIntoConstraints = false
        
        return irregularEvents
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        view.backgroundColor = .ypWhiteDay
        addElements()
        layoutConstraint()
    }
    
    // MARK: - Setup View
    private func addElements() {
        view.addSubview(creationLabel)
        view.addSubview(creationHabbitButton)
        view.addSubview(сreatingIrregularEvents)
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
    
    @objc private func settingCreateHabbitButtonTapped() {
        let createHabbitVC = HabitCreation()
        createHabbitVC.modalPresentationStyle = .pageSheet
        present(createHabbitVC, animated: true, completion: nil)
    }
}
