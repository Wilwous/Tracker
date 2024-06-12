//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Антон Павлов on 06.06.2024.
//

import UIKit

// MARK: - Delegate
protocol CategoryViewControllerDelegate: AnyObject {
    func didSelectCategory(_ category: String)
}

final class CategoryViewController: UIViewController {
    
    // MARK: - Delegate
    weak var delegate: CategoryViewControllerDelegate?
    
    // MARK: - Closures
    var onCategoryAdded: ((String) -> Void)?
    
    // MARK: - Private Properties
    private let viewModel = CategoryViewModel()
    
    private var selectedIndexPath: IndexPath?
    
    private lazy var titleLabel: CustomTitleLabel = {
        let label = CustomTitleLabel(
            text: LocalizationHelper.localizedString("category")
        )
        
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.separatorStyle = .none
        tableView.separatorInset = UIEdgeInsets(
            top: 0, left: 16,
            bottom: 0, right: 16
        )
        
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "cell"
        )
        
        return tableView
    }()
    
    private lazy var addCategoryButton: CustomButton = {
        let button = CustomButton(
            title: LocalizationHelper.localizedString("addCategoryButtonText")
        )
        
        button.addTarget(
            self,
            action: #selector(addCategoryButtonTapped),
            for: .touchUpInside
        )
        
        return button
    }()
    
    private lazy var customSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypGray
        
        return view
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhiteDay
        addElements()
        layoutConstraint()
        bindViewModel()
        viewModel.loadCategories()
        selectedIndexPath = viewModel.selectedIndex
    }
    
    private func bindViewModel() {
        viewModel.onViewStateUpdated = { [weak self] state in
            switch state {
            case .empty:
                self?.StubCategory()
            case .populated:
                self?.deletStubCategory()
                self?.tableView.reloadData()
            }
        }
        
        viewModel.onCategorySelected = { [weak self] category in
            self?.delegate?.didSelectCategory(category)
            self?.tableView.reloadData()
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Setup Metods
    private func addElements() {
        [titleLabel,
         tableView,
         addCategoryButton
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
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120),
            
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        cell.textLabel?.text = viewModel.categories[indexPath.row].headline
        cell.selectionStyle = .none
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.backgroundColor = .ypBackgroundDay
        
        if viewModel.categories.count == 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner,
                .layerMinXMaxYCorner, .layerMaxXMaxYCorner
            ]
            cell.layer.masksToBounds = true
        } else if indexPath.row == 0 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner
            ]
            cell.layer.masksToBounds = true
        } else if indexPath.row == viewModel.categories.count - 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [
                .layerMinXMaxYCorner,
                .layerMaxXMaxYCorner
            ]
            cell.layer.masksToBounds = true
        } else {
            cell.layer.cornerRadius = 0
            cell.layer.masksToBounds = false
        }
    }
    
    private func configureCheck(for cell: UITableViewCell, at indexPath: IndexPath) {
        cell.contentView.subviews.forEach { view in
            if view is UIImageView {
                view.removeFromSuperview()
            }
        }
        
        if indexPath == viewModel.selectedIndex {
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
    
    private func configureSeparator(for cell: UITableViewCell, at indexPath: IndexPath) {
        cell.contentView.subviews.forEach { view in
            if view.backgroundColor == .ypGray && view.frame.height == 0.5 {
                view.removeFromSuperview()
            }
        }
        
        if indexPath.row != viewModel.categories.count - 1 {
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
        
        if indexPath.row == viewModel.categories.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
    
    private func StubCategory() {
        let noResultsLabel = UILabel()
        let text = LocalizationHelper.localizedString("stubsCategory")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.5
        
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.paragraphStyle,
                                      value: paragraphStyle,
                                      range: NSMakeRange(0, attributedString.length)
        )
        
        noResultsLabel.attributedText = attributedString
        noResultsLabel.textColor = .ypBlackDay
        noResultsLabel.textAlignment = .center
        noResultsLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        noResultsLabel.numberOfLines = 2
        noResultsLabel.lineBreakMode = .byWordWrapping
        noResultsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(noResultsLabel)
        
        NSLayoutConstraint.activate([
            noResultsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noResultsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noResultsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            noResultsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        let noResultsImageView = UIImageView(image: UIImage(named: "error1"))
        noResultsImageView.contentMode = .scaleAspectFit
        noResultsImageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(noResultsImageView)
        
        NSLayoutConstraint.activate([
            noResultsImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noResultsImageView.bottomAnchor.constraint(equalTo: noResultsLabel.topAnchor, constant: -8),
            noResultsImageView.widthAnchor.constraint(equalToConstant: 80),
            noResultsImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func updateCategoryView(
        for state: CategoryViewState
    ) {
        switch state {
        case .empty:
            updateStubCategory()
        case .populated:
            updateStubCategory()
            tableView.reloadData()
        }
    }
    
    private func updateStubCategory() {
        if viewModel.categories.isEmpty {
            StubCategory()
        } else {
            deletStubCategory()
        }
    }
    
    private func deletStubCategory() {
        view.subviews.forEach { view in
            if let label = view as? UILabel, label.text?.contains(
                LocalizationHelper.localizedString("stubsCategory")
            ) == true {
                view.removeFromSuperview()
            } else if let imageView = view as? UIImageView,
                      imageView.image == UIImage(named: "error1") {
                view.removeFromSuperview()
            }
        }
    }
    
    // MARK: - Action
    @objc private func addCategoryButtonTapped() {
        let categoryCreationVC = AddCategoryViewController()
        categoryCreationVC.onCategoryAdded = { [weak self] categoryName in
            self?.viewModel.loadCategories()
        }
        
        self.present(categoryCreationVC, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        configureCell(cell, at: indexPath)
        configureSeparator(for: cell, at: indexPath)
        configureCheck(for: cell, at: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.categories.isEmpty {
            StubCategory()
        }
        return viewModel.categories.count
    }
}

// MARK: - UITableViewDelegate
extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCategory(at: indexPath.row)
    }
}
