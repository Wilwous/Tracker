//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Антон Павлов on 01.02.2024.
//

import UIKit

final class StatisticsViewController: UIViewController {
    
    // MARK: - UI Components
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = LocalizationHelper.localizedString("statistic")
        label.font = .boldSystemFont(ofSize: 34)
        label.textColor = .ypBlackDay
        label.contentMode = .scaleAspectFit
        
        return label
    }()
    
    private lazy var emptyStateImageView = {
        let image = UIImageView(image: UIImage(named: "error3"))
        image.contentMode = .scaleAspectFit
        
        return image
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = LocalizationHelper.localizedString("emptyStatisticText")
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlackDay
        
        return label
    }()
    
    // MARK: - Initialization
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhiteDay
        addElemens()
        layoutConstraint()
    }
    
    // MARK: - Setup Methods
    private func addElemens() {
        [titleLabel,
         emptyStateImageView,
         emptyStateLabel
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func layoutConstraint() {
        NSLayoutConstraint.activate([
            emptyStateImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: +8),
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
}
