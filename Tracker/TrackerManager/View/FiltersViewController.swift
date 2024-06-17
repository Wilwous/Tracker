//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Антон Павлов on 15.06.2024.
//

import UIKit

final class FiltersViewController: UIViewController {
    
    // MARK: - Properties
    var onSelectFilter: ((TrackerFilterHelper) -> Void)?
    var selectedFilter: TrackerFilterHelper = .all
    
    private var selectedIndex: IndexPath?
    private var previouslySelectedIndex: IndexPath?
    private let allFilters = [
        "Все трекеры", "Трекеры на сегодня",
        "Завершённые", "Незавершённые"
    ]
    private let filterTypes: [TrackerFilterHelper] = [
        .all, .today, .completed, .uncompleted
    ]
    
    // MARK: - UI Components
    private lazy var titleLabel: CustomTitleLabel = {
        let label = CustomTitleLabel(text: "Фильтры")
        
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.clipsToBounds = true
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 16
        tableView.separatorInset = UIEdgeInsets(
            top: 0, left: 16, bottom: 0, right: 16)
        
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "cell"
        )
        
        return tableView
    }()
    
    private lazy var customSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypGray
        
        return view
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        addElemens()
        layoutConstraint()
    }
    
    // MARK: - Private Methods
    private func hideSeparator() {
        customSeparatorView.isHidden = true
    }
    
    private func showSeparator() {
        customSeparatorView.isHidden = false
    }
    
    // MARK: - Setup Views
    private func addElemens() {
        [titleLabel,
         tableView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func layoutConstraint() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120)
        ])
    }
}

// MARK: - UITableViewDataSource
extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int
    ) -> Int {
        return allFilters.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        configureCell(cell, at: indexPath)
        
        if indexPath.row == allFilters.count - 1 {
            cell.separatorInset = UIEdgeInsets(
                top: 0, left: 16, bottom: 0, right: .greatestFiniteMagnitude
            )
        } else {
            cell.separatorInset = UIEdgeInsets(
                top: 0, left: 16, bottom: 0, right: 16
            )
        }
        return cell
    }
    
    func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        cell.textLabel?.text = allFilters[indexPath.row]
        cell.selectionStyle = .none
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.backgroundColor = .ypBackground
        cell.contentView.subviews.forEach { view in
            if view.backgroundColor == .ypGray && view.frame.height == 0.5 {
                view.removeFromSuperview()
            }
        }
        
        if indexPath.row != allFilters.count - 1 {
            let separatorView = UIView()
            separatorView.backgroundColor = .ypGray
            separatorView.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(separatorView)
            
            NSLayoutConstraint.activate([
                separatorView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20),
                separatorView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -20),
                separatorView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                separatorView.heightAnchor.constraint(equalToConstant: 0.5)
            ])
        }
        
        if allFilters.count == 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [
                .layerMinXMinYCorner, .layerMaxXMinYCorner,
                .layerMinXMaxYCorner, .layerMaxXMaxYCorner
            ]
            cell.layer.masksToBounds = true
        } else if indexPath.row == 0 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [
                .layerMinXMinYCorner, .layerMaxXMinYCorner
            ]
            cell.layer.masksToBounds = true
        } else if indexPath.row == allFilters.count - 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [
                .layerMinXMaxYCorner, .layerMaxXMaxYCorner
            ]
            cell.layer.masksToBounds = true
        } else {
            cell.layer.cornerRadius = 0
            cell.layer.masksToBounds = false
        }
        
        cell.contentView.subviews.forEach { view in
            if view is UIImageView {
                view.removeFromSuperview()
            }
        }
        
        let currentFilter = filterTypes[indexPath.row]
        if currentFilter == selectedFilter {
            let checkboxIcon = UIImageView()
            checkboxIcon.image = UIImage(named: "check")
            checkboxIcon.contentMode = .scaleAspectFit
            checkboxIcon.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(checkboxIcon)
            
            NSLayoutConstraint.activate([
                checkboxIcon.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                checkboxIcon.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                checkboxIcon.widthAnchor.constraint(equalToConstant: 24),
                checkboxIcon.heightAnchor.constraint(equalToConstant: 24)
            ])
        }
    }
}

// MARK: - UITableViewDelegate
extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 75.0
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        selectedIndex = indexPath
        tableView.reloadData()
        
        let selectedFilter = filterTypes[indexPath.row]
        onSelectFilter?(selectedFilter)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.250) { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }
}
