//
//  TrackerCreator.swift
//  Tracker
//
//  Created by Антон Павлов on 09.02.2024.
//

import UIKit

final class TrackerCreator: UIViewController {
    
    private lazy var creationLabel: UILabel = {
        let creation = UILabel()
        creation.text = "Создание трекера"
        creation.textColor = .ypBlackDay
        creation.font = .boldSystemFont(ofSize: 16)
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
    
    override func viewDidLoad() {
        configurationView()
        addElements()
        layoutConstraint()
    }
    
    @objc private func settingCreateHabbitButtonTapped() {
        let createHabbitButton = HabitCreation()
        let createNewHabbitButtonNavigationController = UINavigationController(rootViewController: createHabbitButton)
        present(createNewHabbitButtonNavigationController, animated: true, completion: nil)
    }
    
    private func configurationView() {
        view.backgroundColor = .ypWhiteDay
    }
    
    private func addElements() {
        view.addSubview(creationLabel)
        view.addSubview(creationHabbitButton)
        view.addSubview(сreatingIrregularEvents)
    }
    
    private func layoutConstraint() {
        NSLayoutConstraint.activate([
            creationLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 73),
            creationLabel.centerXAnchor.constraint(equalTo: creationLabel.centerXAnchor),
            
            creationHabbitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            creationHabbitButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            creationHabbitButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            creationHabbitButton.heightAnchor.constraint(equalToConstant: 60),
            creationHabbitButton.bottomAnchor.constraint(equalTo: creationLabel.bottomAnchor, constant: 300),
            
            сreatingIrregularEvents.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            сreatingIrregularEvents.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            сreatingIrregularEvents.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            сreatingIrregularEvents.heightAnchor.constraint(equalToConstant: 60),
            сreatingIrregularEvents.bottomAnchor.constraint(equalTo: creationHabbitButton.bottomAnchor, constant: 67),
        ])
    }
}
