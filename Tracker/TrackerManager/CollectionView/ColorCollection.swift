//
//  ColorCollection.swift
//  Tracker
//
//  Created by Антон Павлов on 19.05.2024.
//

import UIKit

final class ColorCollection: UICollectionViewCell {
    
    static let idetnifier = "ColorCell"
    
    // MARK: - Private Properties
     lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        settingView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func highlightColor() {
        layer.borderWidth = 3.0
        layer.borderColor = colorView.backgroundColor?.withAlphaComponent(0.3).cgColor
        layer.cornerRadius = 8
    }

    func unhighlightColor() {
        layer.borderWidth = 0.0
    }
    
    // MARK: - Setup View
    private func settingView() {
        contentView.addSubview(colorView)
        
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
        ])
    }
}
