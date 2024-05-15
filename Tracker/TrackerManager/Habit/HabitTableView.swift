//
//  HabitTableView.swift
//  Tracker
//
//  Created by Антон Павлов on 14.02.2024.
//

import UIKit

final class HabitTableView: UITableViewCell {
    
    static let cellID = String(describing: HabitTableView.self)
    
    weak var delegate: HabitTableViewDelegate?
    
    // MARK: - Private Properties
    private lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.textColor = .ypBlackDay
        title.font = .systemFont(ofSize: 16, weight: .regular)
        
        return title
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypGray
        label.font = .systemFont(ofSize: 16)
        
        return label
    }()
    
    private lazy var arrowIcon: UIImageView = {
        let arrow = UIImageView()
        arrow.image = UIImage(named: "chevron")
        arrow.contentMode = .scaleAspectFit
        
        return arrow
    }()
    
    private lazy var customSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypGray
        
        return view
    }()
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .ypBackgroundDay
        addElements()
        layoutConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func configureCell(with title: String, subtitle: String?, isFirstCell: Bool) {
        titleLabel.text = title
        customSeparatorView.isHidden = !isFirstCell
        if let subtitle {
            subtitleLabel.text = subtitle
        }
    }
    
    // MARK: - Setup View
    private func addElements() {
        [titleLabel,
         arrowIcon,
         subtitleLabel,
         customSeparatorView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func layoutConstraint() {
        NSLayoutConstraint.activate([
            
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo:  contentView.leadingAnchor, constant: 16),
            
            customSeparatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            customSeparatorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            customSeparatorView.heightAnchor.constraint(equalToConstant: 0.5),
            customSeparatorView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -7),
            subtitleLabel.heightAnchor.constraint(equalToConstant: 22),
            
            arrowIcon.centerYAnchor.constraint(equalTo:  contentView.centerYAnchor),
            arrowIcon.trailingAnchor.constraint(equalTo:  contentView.trailingAnchor, constant: -16)
        ])
    }
}

extension HabitTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            let selectedCell = tableView.cellForRow(at: indexPath) as? HabitTableView
            if let titleText = selectedCell?.titleLabel.text, titleText == "Расписание" {
                delegate?.didSelectTimetable()
            }
        }
    }
}


