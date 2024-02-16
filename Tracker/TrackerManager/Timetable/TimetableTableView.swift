//
//  TimetableTableView.swift
//  Tracker
//
//  Created by Антон Павлов on 15.02.2024.
//

import UIKit

protocol TimetableTableViewDelegate: AnyObject {
    func daySwitchTapped(to isSelected: Bool, of weekDay: WeekDays)
}

final class TimetableTableView: UITableViewCell {
    
    static let cellID = String(describing: TimetableTableView.self)
    
    weak var delegate: TimetableTableViewDelegate?
    
    private var weekDay: WeekDays?
    
    private lazy var WeekDayLabel: UILabel = {
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .ypBackgroundDay
        addElements()
        layoutConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func daySwitchTapped(sender: UISwitch) {
        guard let weekDay = weekDay else { return }
        delegate?.daySwitchTapped(to: sender.isOn, of: weekDay)
    }
    
    func configurationCell(with weekDay: WeekDays, isLastCell: Bool, isSelected: Bool) {
        self.weekDay = weekDay
        WeekDayLabel.text = weekDay.rawValue
        customSeparatorView.isHidden = isLastCell
        daySwitch.isOn = isSelected
    }
    
    private func addElements() {
        contentView.addSubview(WeekDayLabel)
        contentView.addSubview(daySwitch)
        contentView.addSubview(customSeparatorView)
    }
    
    private func layoutConstraint() {
        NSLayoutConstraint.activate([
            WeekDayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            WeekDayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            daySwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            daySwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            customSeparatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            customSeparatorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            customSeparatorView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9),
            customSeparatorView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
}
