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
protocol HabitCreationDelegate: AnyObject {
    func createButtonidTap(tracker: Tracker, category: String)
    func cancelButtonDidTap()
}

final class HabitCreation: UIViewController {

    // MARK: - Delegate
    weak var timetableCreationDelegate: TimetableCreationDelegate?
    weak var habitCreationDelegate: HabitCreationDelegate?
    
    // MARK: - Private Properties
    private let params: GeometricParams
    private var isHabitTracker: Bool
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private var selectedWeekDays: [WeekDay] = []
    private var selectedCategory: String = ""
    private var isIrregularEvent: Bool = false
    
    private var emojis: [String] = [
        "😀", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"
    ]
    
    private var colors: [UIColor] = [
        .colorSelection1, .colorSelection2, .colorSelection3, .colorSelection4, .colorSelection5,
        .colorSelection6, .colorSelection7, .colorSelection8, .colorSelection9, .colorSelection10,
        .colorSelection11, .colorSelection12, .colorSelection13, .colorSelection14, .colorSelection15,
        .colorSelection16, .colorSelection17, .colorSelection18
    ]
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .ypWhiteDay
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        return scrollView
    }()
    
    private lazy var titleLabel = CustomTitleLabel(
        text: isHabitTracker ? "Новая привычка" : "Новое нерегулярное событие"
    )
    
    private lazy var nameTextField: CustomTextField = {
        let textField = CustomTextField(
            placeholder: "Введите название трекера"
        )
        
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
    
    private lazy var stackViewOption: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
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
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.rowHeight = 75
        tableView.estimatedRowHeight = 75
        tableView.layer.cornerRadius = 16
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(HabitTableView.self,
                           forCellReuseIdentifier: HabitTableView.cellID
        )
        return tableView
    }()
    
    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(
            EmojiCollection.self,
            forCellWithReuseIdentifier: EmojiCollection.idetnifier
        )
        
        collectionView.register(
            TrackerHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerHeader.headerIdentifier
        )
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    private lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(
            ColorCollection.self,
            forCellWithReuseIdentifier: ColorCollection.idetnifier
        )
        
        collectionView.register(
            TrackerHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerHeader.headerIdentifier
        )
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    private lazy var creationButton: UIButton = {
        let creation = UIButton()
        creation.setTitle("Создать", for: .normal)
        creation.backgroundColor = .ypGray
        creation.layer.cornerRadius = 16
        creation.translatesAutoresizingMaskIntoConstraints = false
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
        cancel.translatesAutoresizingMaskIntoConstraints = false
        cancel.addTarget(self,
                         action: #selector(cancelButtonTapped),
                         for: .touchUpInside
        )
        return cancel
    }()
    
    // MARK: - Initialization
    init(isHabit: Bool) {
        self.isHabitTracker = isHabit
        self.params = GeometricParams(cellCount: 6, leftInsets: 2, rightInsets: 2, cellSpacing: 5)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        view.backgroundColor = .ypWhiteDay
        addElements()
        layoutConstraint()
        settingSpacing()
        emojiCollectionView.isScrollEnabled = false
        colorCollectionView.isScrollEnabled = false
        nameTextField.delegate = self
        limitMessage.isHidden = true
    }
    
    // MARK: - Setup View
    private func addElements() {
        view.addSubview(scrollView)
        view.addSubview(stackViewButtons)
        
        scrollView.addSubview(stackViewOption)
        
        [titleLabel,
         nameTextField,
         limitMessage,
         tableView,
         emojiCollectionView,
         colorCollectionView
        ].forEach {
            stackViewOption.addArrangedSubview($0)
        }
        
        [cancelButton,
         creationButton
        ].forEach {
            stackViewButtons.addArrangedSubview($0)
        }
    }
    
    private func settingSpacing() {
        stackViewOption.setCustomSpacing(38, after: titleLabel)
        stackViewOption.setCustomSpacing(24, after: nameTextField)
        stackViewOption.setCustomSpacing(50, after: tableView)
        stackViewOption.setCustomSpacing(34, after: emojiCollectionView)
        stackViewOption.setCustomSpacing(16, after: colorCollectionView)
        
        stackViewOption.isLayoutMarginsRelativeArrangement = true
        stackViewOption.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stackViewButtons.layoutMargins = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
    }
    
    private func updateSpacing() {
        let isMessageHidden = limitMessage.isHidden
        let spacingAfterTextField: CGFloat = isMessageHidden ? 24 : 8
        let spacingAfterLimitMessage: CGFloat = isMessageHidden ? 32 : 8
        
        stackViewOption.setCustomSpacing(CGFloat(spacingAfterTextField), after: nameTextField)
        stackViewOption.setCustomSpacing(CGFloat(spacingAfterLimitMessage), after: limitMessage)
    }
    
    
    private func layoutConstraint() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: stackViewButtons.topAnchor),
            
            stackViewOption.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackViewOption.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackViewOption.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackViewOption.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackViewOption.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            tableView.heightAnchor.constraint(equalToConstant: isHabitTracker ? 150 : 75),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 222),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 222),
            
            stackViewButtons.heightAnchor.constraint(equalToConstant: 60),
            stackViewButtons.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackViewButtons.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackViewButtons.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Alert
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
    
    // MARK: - Action
    @objc private func createButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty,
              let emoji = selectedEmoji,
              let color = selectedColor else {
            showAlert(with: "Error", message: "Please enter tracker name.")
            return
        }

        let codableColor = CodableColor(color: color)
        
        let timetable: [WeekDay]
        if isHabitTracker {
            timetable = selectedWeekDays
        } else {
            if let today = WeekDay.from(date: Date()) {
                timetable = [today]
            } else {
                timetable = []
            }
        }
        
        let newTracker = Tracker(
            id: UUID(),
            name: name,
            color: codableColor,
            emoji: emoji,
            timetable: timetable,
            completedDays: []
        )
        
        habitCreationDelegate?.createButtonidTap(
            tracker: newTracker,
            category: selectedCategory
        )
        
        if let trackerViewController = habitCreationDelegate as? TrackerViewController {
            trackerViewController.reload()
        }
        
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
        return isHabitTracker ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: HabitTableView.cellID,
            for: indexPath) as? HabitTableView else {
            assertionFailure("Could not cast to CreateHabitCell")
            return UITableViewCell()
        }
        
        if indexPath.row == 0 {
            cell.configureCell(with: "Категория", subtitle: selectedCategory, isFirstCell: true)
        } else if indexPath.row == 1 {
            let timemable = selectedWeekDays.isEmpty ? "" : selectedWeekDays.map { $0.shortTitle }.joined(separator: ", ")
            cell.configureCell(with: "Расписание", subtitle: timemable, isFirstCell: false)
        }
        cell.selectionStyle = . none
        
        let isLastCell = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        
        if isLastCell {
            cell.hideSeparator()
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            cell.showSeparator()
            cell.layer.cornerRadius = 0
            cell.layer.maskedCorners = []
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension HabitCreation: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            let categoryListVC = CategoryViewController()
            categoryListVC.delegate = self
            categoryListVC.modalPresentationStyle = .pageSheet
            self.present(categoryListVC, animated: true, completion: nil)
        } else if indexPath.row == 1 {
            let viewController = TimetableCreation()
            viewController.delegate = self
            self.timetableCreationDelegate?.didSelectDays(self.selectedWeekDays)
            present(viewController, animated: true, completion: nil)
        }
        updateAddButtonColor()
    }
}

// MARK: - CategoryViewControllerDelegate
extension HabitCreation: CategoryViewControllerDelegate {
    func didSelectCategory(_ category: String) {
        selectedCategory = category
        let indexPath = IndexPath(row: 0, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? HabitTableView {
            cell.subtitleLabel.text = category
            
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
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
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String
    ) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if updatedText.count > 38 {
            limitMessage.isHidden = false
            updateSpacing()
            
            return false
        } else {
            limitMessage.isHidden = true
            updateSpacing()
            updateAddButtonColor()
            
            return true
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HabitCreation: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let totalSpacing = (params.cellSpacing * CGFloat(params.cellCount - 1)) + params.leftInsets + params.rightInsets
        let availableWidth = collectionView.bounds.width - totalSpacing
        let widthPerItem = availableWidth / CGFloat(params.cellCount)
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: params.leftInsets, bottom: 24, right: params.rightInsets)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return params.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 18)
    }
}

// MARK: - UICollectionViewDataSource
extension HabitCreation: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        18
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCollection.idetnifier,
                                                                for: indexPath) as? EmojiCollection else {
                assertionFailure("Could not cast to EmojiCell")
                return UICollectionViewCell()
            }
            
            let emoji = emojis[indexPath.item]
            cell.emojiLabel.text = emoji
            return cell
        } else if collectionView == colorCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollection.idetnifier,
                                                                for: indexPath) as? ColorCollection else {
                assertionFailure("Could not cast to ColorCell")
                return UICollectionViewCell()
            }
            
            let color = colors[indexPath.item]
            cell.colorView.backgroundColor = color
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            assertionFailure( "Failed to cast UICollectionReusableView" )
            return UICollectionReusableView()
        }
        
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackerHeader.headerIdentifier,
            for: indexPath) as? TrackerHeader
        else { assertionFailure("Failed to cast UICollectionReusableView" )
            return UICollectionReusableView()
        }
        
        if collectionView == emojiCollectionView {
            header.configure(with: "Emoji")
        } else if collectionView == colorCollectionView {
            header.configure(with: "Цвет")
        }
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            let selectedCell = collectionView.cellForItem(at: indexPath) as? EmojiCollection
            selectedEmoji = emojis[indexPath.item]
            
            selectedCell?.highlightEmoji()
        } else if collectionView == colorCollectionView {
            let selectedCell = collectionView.cellForItem(at: indexPath) as? ColorCollection
            selectedColor = colors[indexPath.item]
            
            selectedCell?.highlightColor()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            let deselectedCell = collectionView.cellForItem(at: indexPath) as? EmojiCollection
            deselectedCell?.unhighlightEmoji()
            
        } else if collectionView == colorCollectionView {
            let deselectedCell = collectionView.cellForItem(at: indexPath) as? ColorCollection
            deselectedCell?.unhighlightColor()
        }
    }
}
