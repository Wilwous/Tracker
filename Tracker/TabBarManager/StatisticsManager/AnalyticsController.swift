//
//  AnalyticsController.swift
//  Tracker
//
//  Created by Антон Павлов on 16.06.2024.
//

import UIKit

final class AnalyticsController: UIView {
    
    // MARK: - Properties
    private(set) var value: Int = 0
    
    // MARK: - UI Components
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 34)
        label.textColor = .ypBlack
        
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .ypBlack
        
        return label
    }()
    
    private let gradientBorderLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(hex: "#007BFA").cgColor,
            UIColor(hex: "#46E69D").cgColor,
            UIColor(hex: "#FD4C49").cgColor
        ]
        gradient.startPoint = CGPoint(x: 1, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 0)
        
        return gradient
    }()
    
    private let borderShapeLayer: CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.lineWidth = 2
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = UIColor.black.cgColor
        
        return shape
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        addElemets()
        layoutConstraint()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addElemets()
        layoutConstraint()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientBorderLayer.frame = bounds
        
        let path = UIBezierPath(
            roundedRect: bounds.insetBy(
                dx: borderShapeLayer.lineWidth / 2,
                dy: borderShapeLayer.lineWidth / 2
            ), cornerRadius: 16
        )
        borderShapeLayer.path = path.cgPath
    }
    
    // MARK: - Setup Methods
    private func addElemets() {
        layer.addSublayer(gradientBorderLayer)
        gradientBorderLayer.mask = borderShapeLayer
        
        [valueLabel,
         descriptionLabel
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }
    private func layoutConstraint() {
        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            
            descriptionLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 7),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Configuration
    func configure(value: Int, description: String) {
        self.value = value
        valueLabel.text = "\(value)"
        descriptionLabel.text = description
    }
}
