//
//  addCategoryViewController.swift
//  Tracker
//
//  Created by Антон Павлов on 06.06.2024.
//

import UIKit

final class AddCategoryViewController: UIViewController {
    
    // MARK: - Properties
    var onCategoryAdded: ((String) -> Void)?
    private var viewModel = AddCategoryViewModel()
    
    private lazy var titleLabel: CustomTitleLabel = {
        let label = CustomTitleLabel(
            text: LocalizationHelper.localizedString(
                "newCategory"
            )
        )
        
        return label
    }()
    
    private lazy var nameTextField: UITextField = {
        let textField = CustomTextField(
            placeholder: LocalizationHelper.localizedString(
                "enterCategoryName"
            )
        )
        
        textField.addTarget(
            self, action: #selector(textFieldDidChange(_ :)),
            for: .editingChanged
        )
        
        return textField
    }()
    
    private lazy var creationButton: CustomButton = {
        let button = CustomButton(
            title: LocalizationHelper.localizedString(
                "doneButtonText"
            )
        )
        
        button.addTarget(
            self,
            action: #selector(creationButtonTapped),
            for: .touchUpInside
        )
        return button
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhiteDay
        nameTextField.delegate = self
        addElements()
        layoutConstraint()
        bindViewModel()
        validateInitialButtonState()
    }
    
    // MARK: - Setup Methods
    private func addElements() {
        [titleLabel,
         nameTextField,
         creationButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func layoutConstraint() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nameTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 87),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            creationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            creationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            creationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            creationButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Binding ViewModel
    private func bindViewModel() {
        viewModel.onCategoryCreation = { [weak self] categoryName in
            self?.onCategoryAdded?(categoryName)
            self?.dismiss(animated: true, completion: nil)
        }
        
        viewModel.onCreationButtonStateUpdated = { [weak self] isEnabled in
            self?.creationButton.isEnabled = isEnabled
            self?.creationButton.backgroundColor = isEnabled ? .ypBlackDay : .ypGray
        }
    }
    
    // MARK: - Private Methods
    private func validateInitialButtonState() {
        viewModel.validateCategoryName(nameTextField.text)
    }
    
    // MARK: - Actions
    @objc private func creationButtonTapped() {
        if let categoryName = nameTextField.text, !categoryName.isEmpty {
            viewModel.addCategory(name: categoryName)
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        viewModel.validateCategoryName(textField.text)
    }
}

// MARK: - UITextFieldDelegate
extension AddCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


