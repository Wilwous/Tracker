//
//  CustomTitleLabel.swift
//  Tracker
//
//  Created by Антон Павлов on 19.05.2024.
//

import UIKit

final class CustomTitleLabel: UILabel {
    
    // MARK: - Initialization
    init(text: String) {
        super.init(frame: .zero)
        self.text = text
        font = .systemFont(ofSize: 16, weight: .medium)
        textColor = .ypBlackDay
        textAlignment = .center
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
            topAnchor.constraint(equalTo: superview.topAnchor, constant: 27),
            centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            heightAnchor.constraint(equalToConstant: 22)
        ])
    }
}
