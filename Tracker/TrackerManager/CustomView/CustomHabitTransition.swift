//
//  CustomHabitTransition.swift
//  Tracker
//
//  Created by Антон Павлов on 19.05.2024.
//

import UIKit

final class CustomHabitTransition: UIButton {
    
    // MARK: - Initialization
    init(title: String) {
        super.init(frame: .zero)
        titleLabel?.font = .boldSystemFont(ofSize: 16)
        setTitle(title, for: .normal)
        setTitleColor(.ypWhiteDay, for: .normal)
        layer.cornerRadius = 16
        contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        backgroundColor = .ypBlackDay
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            layoutConstraints()
        }
    }
    
    // MARK: - Setup View
    private func layoutConstraints() {
        guard let superview = superview else { return }
        
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 20),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -20),
            heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func addAction(target: Any?, action: Selector) {
        addTarget(target, action: action, for: .touchUpInside)
    }
}
