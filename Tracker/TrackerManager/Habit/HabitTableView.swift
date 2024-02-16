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
    
    private lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.textColor = .ypBlackDay
        title.font = .systemFont(ofSize: 16, weight: .regular)
        title.translatesAutoresizingMaskIntoConstraints = false
        
        return title
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypGray
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var arrowIcon: UIImageView = {
        let arrow = UIImageView()
        arrow.image = UIImage(named: "chevron")
        arrow.contentMode = .scaleAspectFit
        arrow.translatesAutoresizingMaskIntoConstraints = false
        
        return arrow
    }()
    
    private lazy var customSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypGray
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .ypBackgroundDay
        addElements()
        layoutConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(with title: String, subtitle: String?, isFirstCell: Bool) {
        titleLabel.text = title
        customSeparatorView.isHidden = !isFirstCell
        if let subtitle {
            subtitleLabel.text = subtitle
        }
    }
    
    private func addElements() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(arrowIcon)
        contentView.addSubview(customSeparatorView)
    }
    
    private func layoutConstraint() {
        NSLayoutConstraint.activate([
            
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo:  contentView.leadingAnchor, constant: 16),
            
            customSeparatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            customSeparatorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            customSeparatorView.heightAnchor.constraint(equalToConstant: 0.5),
            customSeparatorView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9),
            
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


