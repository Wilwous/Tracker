//
//  TimetableCreation.swift
//  Tracker
//
//  Created by Антон Павлов on 15.02.2024.
//

import UIKit

protocol TimetableCreationDelegate: AnyObject {
    func didSelectDays(_ days: [WeekDays])
}

final class TimetableCreation: UIViewController, TimetableTableViewDelegate {

    weak var delegate: TimetableCreationDelegate?

    private var selectedWeekDay: Set<WeekDays> = []
    
    private lazy var timetableLabel: UILabel = {
        let timetable = UILabel()
        timetable.text = "Расписание"
        timetable.textColor = .ypBlackDay
        timetable.font = .systemFont(ofSize: 16, weight: .medium)
        timetable.translatesAutoresizingMaskIntoConstraints = false
        
        return timetable
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.clipsToBounds = true
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .ypBackgroundDay
        tableView.layer.cornerRadius = 16
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(TimetableTableView.self,
                           forCellReuseIdentifier: TimetableTableView.cellID
        )
        
        return tableView
    }()
    
    private lazy var doneButton: UIButton = {
        let done = UIButton(type: .system)
        done.setTitle("Готово", for: .normal)
        done.setTitleColor(.white, for: .normal)
        done.backgroundColor = .ypBlackDay
        done.layer.cornerRadius = 16
        done.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        done.translatesAutoresizingMaskIntoConstraints = false
        done.addTarget(self,
                       action: #selector(doneButtonTapped),
                       for: .touchUpInside)
        
        return done
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurationView()
        addElements()
        layoutConstraint()
    }
    
    @objc private func doneButtonTapped() {
        let weekDays = Array(selectedWeekDay)
        delegate?.didSelectDays(weekDays)
        dismiss(animated: true, completion: nil)
    }
    
    internal func daySwitchTapped(to isSelected: Bool, of weekDay: WeekDays) {
        if isSelected {
            selectedWeekDay.insert(weekDay)
        } else {
            selectedWeekDay.remove(weekDay)
        }
    }
    
    private func configurationView() {
        view.backgroundColor = .ypWhiteDay
    }
    
    private func addElements() {
        view.addSubview(timetableLabel)
        view.addSubview(tableView)
        view.addSubview(doneButton)
    }
    
    private func layoutConstraint() {
        NSLayoutConstraint.activate([
            timetableLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            timetableLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timetableLabel.heightAnchor.constraint(equalToConstant: 22),
            
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 87),
            tableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -47),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
}

extension TimetableCreation: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        7
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TimetableTableView.cellID,
            for: indexPath) as? TimetableTableView else {
            assertionFailure("Could not cast to CreateHabitCell")
            
            return UITableViewCell()
        }
        
        let weekDay = WeekDays.allCases[indexPath.row]
        cell.configurationCell(
            with: weekDay,
            isLastCell: indexPath.row == 6,
            isSelected: selectedWeekDay.contains(weekDay)
        )
        cell.delegate = self
        return cell
    }
}
