//
//  HabitCreation.swift
//  Tracker
//
//  Created by Антон Павлов on 14.02.2024.
//

import UIKit

// MARK: - HabitTableViewDelegate
protocol HabitTableViewDelegate: AnyObject {
    func didSelectTimetable()
}

// MARK: - HabitCreationDelegate
protocol HabitCreationDelegate: AnyObject{
    func createButtonidTap(tracker: Tracker, category: String)
    func cancelButtonDidTap()
}

final class HabitCreation: UIViewController {
    
    // MARK: - Delegate
    weak var timetableCreationDelegate: TimetableCreationDelegate?
    weak var habitCreationDelegate: HabitCreationDelegate?
    
    // MARK: - Private Properties
    private var selectedWeekDays: [WeekDay] = []
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .ypWhiteDay
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        return scrollView
    }()
    
    private lazy var newhabitLabel: UILabel = {
        let newhabitLabel = UILabel()
        newhabitLabel.text = "Новая привычка"
        newhabitLabel.textColor = .ypBlackDay
        newhabitLabel.textAlignment = .center
        newhabitLabel.font = .systemFont(ofSize: 16)
        newhabitLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return newhabitLabel
    }()
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.textAlignment = .left
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 16
        textField.backgroundColor = .ypBackgroundDay
        textField.rightViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let leftIndent = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = leftIndent
        textField.leftViewMode = .always
        
        let rightIndent = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.rightView = rightIndent
        textField.rightViewMode = .always
        
        return textField
    }()
    
    private lazy var limitMessage: UILabel = {
        let limit = UILabel()
        limit.text = "Ограничение 38 символов"
        limit.textColor = .ypRed
        limit.textAlignment = .center
        limit.font = .systemFont(ofSize: 17, weight: .regular)
        limit.translatesAutoresizingMaskIntoConstraints = false
        
        return limit
    }()
    
    private lazy var stackViewButtons: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.isLayoutMarginsRelativeArrangement = true
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
    }()
    
    private lazy var stackViewOption: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.rowHeight = 75
        tableView.estimatedRowHeight = 75
        tableView.layer.cornerRadius = 16
        tableView.showsVerticalScrollIndicator = false
        
        tableView.register(HabitTableView.self,
                           forCellReuseIdentifier: HabitTableView.cellID
        )
        
        return tableView
    }()
    
    private lazy var creationButton: UIButton = {
        let creation = UIButton()
        creation.setTitle("Создать", for: .normal)
        creation.backgroundColor = .ypGray
        creation.layer.cornerRadius = 16
        
        creation.addTarget(self,
                           action: #selector(createButtonTapped),
                           for: .touchUpInside
        )
        
        return creation
    }()
    
    private lazy var cancelButton: UIButton = {
        let cancel = UIButton()
        cancel.setTitle("Отменить", for: .normal)
        cancel.setTitleColor(.red, for: .normal)
        cancel.backgroundColor = .ypWhiteDay
        cancel.layer.borderWidth = 1
        cancel.layer.cornerRadius = 16
        cancel.layer.borderColor = UIColor.ypRed.cgColor
        
        cancel.addTarget(self,
                         action: #selector(cancelButtonTapped),
                         for: .touchUpInside
        )
        
        return cancel
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        view.backgroundColor = .ypWhiteDay
        
        addElements()
        layoutConstraint()
        settingSpacing()
        
        nameTextField.delegate = self
        limitMessage.isHidden = true
    }
    
    // MARK: - Setup View
    private func addElements() {
        view.addSubview(scrollView)
        
        scrollView.addSubview(stackViewOption)
        
        stackViewOption.addArrangedSubview(newhabitLabel)
        stackViewOption.addArrangedSubview(nameTextField)
        stackViewOption.addArrangedSubview(limitMessage)
        stackViewOption.addArrangedSubview(tableView)
        stackViewOption.addArrangedSubview(stackViewButtons)
        
        stackViewButtons.addArrangedSubview(cancelButton)
        stackViewButtons.addArrangedSubview(creationButton)
    }
    
    private func settingSpacing() {
        stackViewOption.setCustomSpacing(38, after: newhabitLabel)
        stackViewOption.setCustomSpacing(20, after: limitMessage)
        stackViewOption.setCustomSpacing(20, after: nameTextField)
        stackViewOption.setCustomSpacing(508, after: tableView)
        
        stackViewOption.isLayoutMarginsRelativeArrangement = true
        stackViewOption.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stackViewButtons.layoutMargins = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
    }
    
    private func layoutConstraint() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stackViewOption.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackViewOption.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackViewOption.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackViewOption.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackViewOption.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            newhabitLabel.topAnchor.constraint(equalTo: stackViewOption.topAnchor, constant: 27),
            newhabitLabel.heightAnchor.constraint(equalToConstant: 22),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            limitMessage.heightAnchor.constraint(equalToConstant: 22),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            stackViewButtons.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func showAlert(with title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func updateAddButtonColor() {
        if let text = nameTextField.text, !text.isEmpty || !selectedWeekDays.isEmpty {
            creationButton.isEnabled = true
            creationButton.backgroundColor = .ypBlackDay
        } else {
            creationButton.isEnabled = false
            creationButton.backgroundColor = .ypGray
        }
    }
    
    @objc private func createButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(with: "Error", message: "Please enter tracker name.")
            return
        }
        
        let newTracker = Tracker(id: UUID(),
                                 name: name,
                                 color: "",
                                 emoji: "",
                                 timetable: self.selectedWeekDays,
                                 completedDays: [])
        
        habitCreationDelegate?.createButtonidTap(tracker: newTracker,
                                                 category: "Category"
        )
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
        habitCreationDelegate?.cancelButtonDidTap()
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension HabitCreation: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: HabitTableView.cellID,
            for: indexPath) as? HabitTableView else {
            assertionFailure("Could not cast to CreateHabitCell")
            
            return UITableViewCell()
        }
        
        if indexPath.row == 0 {
            cell.configureCell(with: "Категория", subtitle: "Category", isFirstCell: true)
        }  else if indexPath.row == 1 {
            let timemable = selectedWeekDays.isEmpty ? "" : selectedWeekDays.map { $0.shortTitle }.joined(separator: ", ")
            cell.configureCell(with: "Расписание", subtitle: timemable, isFirstCell: false)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension HabitCreation: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            print("Category Selected")
        } else if indexPath.row == 1 {
            let viewController = TimetableCreation()
            viewController.delegate = self
            self.timetableCreationDelegate?.didSelectDays(self.selectedWeekDays)
            present(viewController, animated: true, completion: nil)
        }
        updateAddButtonColor()
    }
}

// MARK: - TimetableCreationDelegate
extension HabitCreation: TimetableCreationDelegate {
    func didSelectDays(_ days: [WeekDay]) {
        selectedWeekDays = days
        tableView.reloadData()
    }
}

// MARK: - UITextFieldDelegate
extension HabitCreation: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        limitMessage.isHidden = updatedText.count <= 38
        
        updateAddButtonColor()
        
        return updatedText.count <= 38
    }
}
