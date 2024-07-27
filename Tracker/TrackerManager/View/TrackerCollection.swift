//
//  TrackerCollection.swift
//  Tracker
//
//  Created by Антон Павлов on 20.02.2024.
//

import UIKit

protocol TrackerCollectionDelegate: AnyObject {
    func completeTracker(id: UUID, at indexPath: IndexPath)
    func uncompleteTracker(id: UUID, at indexPath: IndexPath)
    func selectedDate() -> Date
}

final class TrackerCollection: UICollectionViewCell {
    
    static let cellIdetnifier = "TrackerCollection"
    
    weak var delegate: TrackerCollectionDelegate?
    
    // MARK: - Private Properties
    private var isCompletedToday = false
    private var trackerId: UUID?
    private var indexPath: IndexPath?
    
    private lazy var emojiLabel: UILabel = {
        let emoji = UILabel()
        emoji.textAlignment = .center
        emoji.font = .systemFont(ofSize: 16)
        
        return emoji
    }()
    
    private lazy var emojiBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypWhiteDay.withAlphaComponent(0.3)
        
        return view
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Поливать растения"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        return label
    }()
    
    private lazy var bottomBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    private lazy var topBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(resource: .colorSelection18)
        
        return view
    }()
    
    private lazy var daysCounterLabel: UILabel = {
        let daysCounter = UILabel()
        daysCounter.textAlignment = .left
        daysCounter.font = .systemFont(ofSize: 12, weight: .medium)
        daysCounter.text = "0 дней"
        
        return daysCounter
    }()
    
    private lazy var plusImage: UIImage? = {
        let image = UIImage(systemName: "plus")
        let coloredImage = image?.withTintColor(.ypWhiteDay, renderingMode: .alwaysOriginal)
        let configuredImage = coloredImage?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 12, weight: .bold))
        
        return configuredImage
    }()
    
    private lazy var completeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .colorSelection18
        button.setImage(plusImage, for: .normal)
        button.addTarget(self,
                         action: #selector(completeButtonTapped),
                         for: .touchUpInside
        )
        
        return button
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        addElements()
        layoutConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        topBackgroundView.layer.cornerRadius = 16
        topBackgroundView.layer.masksToBounds = true
        
        emojiBackgroundView.layer.cornerRadius = 12
        emojiBackgroundView.clipsToBounds = true
        
        completeButton.layer.cornerRadius = 17
        completeButton.clipsToBounds = true
    }
    
    // MARK: - Public Methods
    func configuration(with tracker: Tracker,
                       isCompletedToday: Bool,
                       completedDays: Int,
                       indexPath: IndexPath
    ) {
        self.trackerId = tracker.id
        self.isCompletedToday = isCompletedToday
        self.indexPath = indexPath
        
        emojiLabel.text = tracker.emoji
        nameLabel.text = tracker.name
        topBackgroundView.backgroundColor =  UIColor.color(from: tracker.color) ?? .blue
        completeButton.backgroundColor = topBackgroundView.backgroundColor
        
        let wordDays = convertCompletedDays(completedDays)
        daysCounterLabel.text = wordDays
        
        let buttonImage = isCompletedToday ? UIImage(named: "done") : plusImage
        completeButton.setImage(buttonImage, for: .normal)
        completeButton.alpha = isCompletedToday ? 0.3 : 1
    }
    
    // MARK: - Private Methods
    private func convertCompletedDays(_ completedDays: Int) -> String {
        let lasyNumber = completedDays % 10
        let lastTwoNumbers = completedDays % 100
        if lastTwoNumbers >= 11 && lastTwoNumbers <= 19 {
            return "\(completedDays) дней"
        }
        
        switch lasyNumber {
        case 1:
            return "\(completedDays) день"
        case 2, 3, 4:
            return "\(completedDays) дня"
        default:
            return "\(completedDays) дней"
        }
    }
    
    // MARK: - Setup View
    private func addElements() {
        [topBackgroundView,
         bottomBackgroundView,
         emojiBackgroundView,
         emojiLabel,
         nameLabel,
         daysCounterLabel,
         completeButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func layoutConstraint() {
        NSLayoutConstraint.activate([
            topBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
            topBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            topBackgroundView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: topBackgroundView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: topBackgroundView.trailingAnchor, constant: -12),
            nameLabel.heightAnchor.constraint(equalToConstant: 34),
            nameLabel.bottomAnchor.constraint(equalTo: topBackgroundView.bottomAnchor, constant: -12),
            
            bottomBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomBackgroundView.topAnchor.constraint(equalTo: topBackgroundView.bottomAnchor),
            bottomBackgroundView.heightAnchor.constraint(equalToConstant: 58),
            
            completeButton.trailingAnchor.constraint(equalTo: bottomBackgroundView.trailingAnchor, constant: -12),
            completeButton.bottomAnchor.constraint(equalTo: bottomBackgroundView.bottomAnchor, constant: -16),
            completeButton.widthAnchor.constraint(equalToConstant: 34),
            completeButton.heightAnchor.constraint(equalToConstant: 34),
            
            daysCounterLabel.centerYAnchor.constraint(equalTo: completeButton.centerYAnchor),
            daysCounterLabel.leadingAnchor.constraint(equalTo: bottomBackgroundView.leadingAnchor, constant: 12),
        ])
    }
    
    // MARK: - Action
    @objc private func completeButtonTapped() {
        guard let trackerId = trackerId, let indexPath = indexPath else {
            assertionFailure("No trackerId or indexPath")
            return
        }
        
        let currentDate = Date()
        let selectedDate = delegate?.selectedDate() ?? Date()
        if Calendar.current.compare(selectedDate, to: currentDate, toGranularity: .day) != .orderedDescending {
            if isCompletedToday {
                delegate?.uncompleteTracker(id: trackerId, at: indexPath)
            } else {
                delegate?.completeTracker(id: trackerId, at: indexPath)
            }
            isCompletedToday.toggle()
        } else {
            print("You cannot mark future dates.")
        }
    }
}


