//
//  TimetableTableView.swift
//  Tracker
//
//  Created by Антон Павлов on 15.02.2024.
//

import UIKit

// MARK: - TimetableTableViewDelegate
protocol TimetableTableViewDelegate: AnyObject {
    func daySwitchDidTapped(to isSelected: Bool, of weekDay: WeekDay)
}

// MARK: - TimetableTableView
final class TimetableTableView: UITableViewCell {
    
    static let cellID = String(describing: TimetableTableView.self)
    
    weak var delegate: TimetableTableViewDelegate?
    
    // MARK: - Private properties
    private var weekDay: WeekDay?
    
    private lazy var weekDayLabel: UILabel = {
        let WeekDay = UILabel()
        WeekDay.textColor = .ypBlackDay
        WeekDay.font = .systemFont(ofSize: 17, weight: .regular)
        WeekDay.translatesAutoresizingMaskIntoConstraints = false
        
        return WeekDay
    }()
    
    private lazy var customSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypGray
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var daySwitch: UISwitch = {
        let daySwitch = UISwitch()
        daySwitch.onTintColor = .ypBlue
        daySwitch.translatesAutoresizingMaskIntoConstraints = false
        daySwitch.addTarget(self,
                            action: #selector(daySwitchTapped),
                            for: .valueChanged)
        
        return daySwitch
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
    func configurationCell(with weekDay: WeekDay, isLastCell: Bool, isSelected: Bool) {
        self.weekDay = weekDay
        weekDayLabel.text = weekDay.rawValue
        customSeparatorView.isHidden = isLastCell
        daySwitch.isOn = isSelected
    }
    
    // MARK: - Setup View
    private func addElements() {
        contentView.addSubview(weekDayLabel)
        contentView.addSubview(daySwitch)
        contentView.addSubview(customSeparatorView)
    }
    
    private func layoutConstraint() {
        NSLayoutConstraint.activate([
            weekDayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            weekDayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            daySwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            daySwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            customSeparatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            customSeparatorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            customSeparatorView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9),
            customSeparatorView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    // MARK: - Actions
    @objc private func daySwitchTapped(sender: UISwitch) {
        guard let weekDay = weekDay else { return }
        delegate?.daySwitchDidTapped(to: sender.isOn, of: weekDay)
    }
}

