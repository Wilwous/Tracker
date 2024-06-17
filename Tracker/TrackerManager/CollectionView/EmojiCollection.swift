//
//  EmojiCollection.swift
//  Tracker
//
//  Created by Антон Павлов on 19.05.2024.
//

import UIKit

final class EmojiCollection: UICollectionViewCell {
    
    // MARK: - Properties
    static let idetnifier = "EmojiCollection"
    
    // MARK: - UI Components
    lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.text = "🤡"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        settingView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Metods
    func highlightEmoji() {
        contentView.backgroundColor = .ypLightGray
        contentView.layer.cornerRadius = 16
    }

    func unhighlightEmoji() {
        contentView.backgroundColor = .clear
    }
    
    // MARK: - Setup View
    private func settingView() {
        contentView.addSubview(emojiLabel)
        
        self.layer.cornerRadius = 16
        self.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
