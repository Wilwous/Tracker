//
//  TrackerCollection.swift
//  Tracker
//
//  Created by Антон Павлов on 20.02.2024.
//

import UIKit

protocol TrackerCollectionDelegate: AnyObject {
    func markTrackerAsCompleted(id: UUID, at indexPath: IndexPath)
    func markTrackerAsUncompleted(id: UUID, at indexPath: IndexPath)
}

final class TrackerCollection: UICollectionViewCell {
    
    // MARK: - Context Menu
    var onPin: (() -> Void)?
    var onEdit: (() -> Void)?
    var onDelete: (() -> Void)?
    
    var isPinned: Bool = false {
        didSet {
            pinImageView .isHidden = !isPinned
            pinActionTitle = isPinned ? "Открепить" : "Закрепить"
        }
    }
    
    static let cellIdetnifier = "TrackerCollection"
    
    weak var delegate: TrackerCollectionDelegate?
    
    // MARK: - Private Properties
    private var isCompletedToday = false
    private var trackerId: UUID?
    private var indexPath: IndexPath?
    private var pinActionTitle = "Закрепить"
    
    // MARK: - UI Components
    private lazy var emojiLabel: UILabel = {
        let emoji = UILabel()
        emoji.textAlignment = .center
        emoji.font = .systemFont(ofSize: 16)
        
        return emoji
    }()
    
    private lazy var emojiBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypWhite.withAlphaComponent(0.3)
        
        return view
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
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
        daysCounter.text = LocalizationHelper.localizedString("daysMany")
        
        return daysCounter
    }()
    
    private lazy var plusImage: UIImage? = {
        let image = UIImage(systemName: "plus")
        let coloredImage = image?.withTintColor(.ypWhite, renderingMode: .alwaysOriginal)
        let configuredImage = coloredImage?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        )
        return configuredImage
    }()
    
    private lazy var pinImageView : UIImageView = {
        let pin = UIImageView()
        pin.image = UIImage(named: "pin")
        
        return pin
    }()
    
    private lazy var completeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .colorSelection18
        button.setImage(plusImage, for: .normal)
        button.addTarget(
            self,
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
        setupContextMenu()
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
    func configuration(
        with tracker: Tracker,
        isCompletedToday: Bool,
        completedDays: Int,
        indexPath: IndexPath,
        isPinned: Bool
    ) {
        self.trackerId = tracker.id
        self.isCompletedToday = isCompletedToday
        self.indexPath = indexPath
        self.isPinned = isPinned
        
        emojiLabel.text = tracker.emoji
        nameLabel.text = tracker.name
        topBackgroundView.backgroundColor = tracker.color.getUIColor()
        completeButton.backgroundColor = topBackgroundView.backgroundColor
        
        let wordDays = convertCompletedDays(completedDays)
        daysCounterLabel.text = wordDays
        
        let buttonImage = isCompletedToday ? UIImage(named: "done") : plusImage
        completeButton.setImage(buttonImage, for: .normal)
        completeButton.alpha = isCompletedToday ? 0.3 : 1
    }
    
    // MARK: - Private Methods
    func convertCompletedDays(_ completedDays: Int) -> String {
        let lasyNumber = completedDays % 10
        let lastTwoNumbers = completedDays % 100
        
        if lasyNumber == 1 && lastTwoNumbers != 11 {
            return "\(completedDays) \(LocalizationHelper.localizedString("day"))"
        } else if lasyNumber >= 2 && lastTwoNumbers <= 4 && (lastTwoNumbers < 10 || lastTwoNumbers >= 20) {
            return "\(completedDays) \(LocalizationHelper.localizedString("days"))"
        } else {
            return "\(completedDays) \(LocalizationHelper.localizedString("daysMany"))"
        }
    }
    
    // MARK: - ContextMenu
    private func setupContextMenu() {
        let interaction = UIContextMenuInteraction(delegate: self)
        topBackgroundView.addInteraction(interaction)
    }
    
    // MARK: - Setup View
    private func addElements() {
        [topBackgroundView,
         bottomBackgroundView,
         daysCounterLabel,
         completeButton,
         pinImageView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        [emojiBackgroundView,
         emojiLabel,
         nameLabel,
         pinImageView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            topBackgroundView.addSubview($0)
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
            
            pinImageView .topAnchor.constraint(equalTo: topBackgroundView.topAnchor, constant: 12),
            pinImageView .trailingAnchor.constraint(equalTo: topBackgroundView.trailingAnchor, constant: -4),
            pinImageView .widthAnchor.constraint(equalToConstant: 24),
            pinImageView .heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    // MARK: - Action
    @objc private func completeButtonTapped() {
        AnalyticsService.didClickTrack()
        guard let trackerId = trackerId, let indexPath = indexPath else {
            assertionFailure("No trackerId or indexPath")
            return
        }
        
        if isCompletedToday {
            delegate?.markTrackerAsUncompleted(id: trackerId, at: indexPath)
        } else {
            delegate?.markTrackerAsCompleted(id: trackerId, at: indexPath)
        }
    }
}

// MARK: - UIContextMenuInteractionDelegate
extension TrackerCollection: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] suggestedActions in
            guard let self = self else { return nil }
            
            let pinAction = UIAction(title: self.pinActionTitle) { [weak self] action in
                self?.onPin?()
            }
            
            let editAction = UIAction(title: "Редактировать") { [weak self] action in
                AnalyticsService.didClickEdit()
                self?.onEdit?()
            }
            
            let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { [weak self] action in
                AnalyticsService.didClickDelete()
                self?.onDelete?()
            }
            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        }
    }
}
