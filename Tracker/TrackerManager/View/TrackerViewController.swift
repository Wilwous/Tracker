//
//  ViewController.swift
//  Tracker
//
//  Created by Антон Павлов on 17.01.2024.
//

import UIKit

final class TrackerViewController: UIViewController {
    
    // MARK: - Delegate
    weak var habitCreationDelegate: HabitCreationDelegate?
    
    // MARK: - Private Properties
    private var currentDate: Date = Date()
    private var params: GeometricParams
    private var dataSource = DataSource.shared
    private var trackers: [Tracker] = []
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var completedTrackerIds: Set<UUID> = []
    private var completedIrregularEvents: Set<UUID> = []
    private var trackerCreationDates: [UUID: Date] = [:]
    private var isSearching = false
    
    private lazy var trackersViewStubs: TrackersViewStubs = {
        let stubs = TrackersViewStubs()
        return stubs
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = LocalizationHelper.localizedString("search")
        searchBar.searchBarStyle = .minimal
        
        return searchBar
    }()
    
    private lazy var dateSetting: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.calendar.firstWeekday = 2
        datePicker.clipsToBounds = true
        
        let datePickerItem = UIBarButtonItem(customView: datePicker)
        navigationItem.rightBarButtonItem = datePickerItem
        
        datePicker.addTarget(self,
                             action: #selector(dateSettingTapped),
                             for: .valueChanged)
        
        return datePicker
    }()
    
    private lazy var trackerCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.register(
            TrackerCollection.self,
            forCellWithReuseIdentifier: TrackerCollection.cellIdetnifier
        )
        collectionView.register(
            TrackerHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerHeader.headerIdentifier
        )
        return collectionView
    }()
    
    // MARK: - Initialization
    init() {
        self.params = GeometricParams(cellCount: 2, leftInsets: 16, rightInsets: 16, cellSpacing: 9)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhiteDay
        CoreDataStack.shared.trackerStore.delegate = self
        CoreDataStack.shared.trackerRecordStore.delegate = self
        CoreDataStack.shared.trackerCategoryStore.delegate = self
        completedTrackers = CoreDataStack.shared.trackerRecordStore.fetchAllCompletedTrackers()
        addElements()
        layoutConstraint()
        settingNavigationBar()
        reload()
    }
    
    // MARK: - Public Methods
    func reload() {
        categories = CoreDataStack.shared.trackerStore.fetchTrackersGroupedByCategory()
        
        guard let fetchedObjects = CoreDataStack.shared.trackerStore.fetchedResultsController?.fetchedObjects else {
            return
        }
        trackerCreationDates = fetchedObjects.reduce(into: [:]) { dict, tracker in
            if let id = tracker.id, let creationDate = tracker.creationDate {
                dict[id] = creationDate
            }
        }
        
        reloadVisibleCategories(text: searchBar.text, date: dateSetting.date)
        trackerCollectionView.reloadData()
    }
    
    func reloadVisibleCategories(text: String?, date: Date) {
        let filterText = (text ?? "").lowercased()
        let filterWeekday = WeekDay.from(date: date)
        let textFilteredCategories = categories.compactMap { category -> TrackerCategory? in
            let filteredTrackers = category.trackers.filter { tracker in
                filterText.isEmpty || tracker.name.lowercased().contains(filterText)
            }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(headline: category.headline, trackers: filteredTrackers)
        }
        
        if let filterWeekday = filterWeekday {
            visibleCategories = textFilteredCategories.compactMap { category -> TrackerCategory? in
                let filteredTrackers = category.trackers.filter { tracker in
                    if tracker.timetable.isEmpty {
                        if let creationDate = trackerCreationDates[tracker.id],
                           Calendar.current.isDate(creationDate, inSameDayAs: date) {
                            return !completedIrregularEvents.contains(tracker.id)
                        } else {
                            return false
                        }
                    }
                    return tracker.timetable.contains { $0.numberValue == filterWeekday.numberValue }
                }
                return filteredTrackers.isEmpty ? nil : TrackerCategory(
                    headline: category.headline, trackers: filteredTrackers
                )
            }
        } else {
            visibleCategories = textFilteredCategories
        }
        
        trackerCollectionView.reloadData()
        updateCategoriesView()
    }
    
    private func updateCategoriesView() {
        trackersViewStubs.isHidden = !visibleCategories.isEmpty
        trackerCollectionView.backgroundView = visibleCategories.isEmpty ? trackersViewStubs : nil
    }
    
    // MARK: - Setup View
    private func settingNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        title = LocalizationHelper.localizedString("trackers")
        
        let addTrackerButton = UIButton(type: .custom)
        addTrackerButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        addTrackerButton.addTarget(self,
                                   action: #selector(addTrackerButtonTapped),
                                   for: .touchUpInside)
        
        let addTrackerButtonItem = UIBarButtonItem(customView: addTrackerButton)
        navigationItem.leftBarButtonItem = addTrackerButtonItem
        
        if let addTrakerImage = UIImage(named: "addTracker")?.withRenderingMode(.alwaysOriginal) {
            addTrackerButton.setImage(addTrakerImage, for: .normal)
        }
    }
    
    private func addElements() {
        [searchBar,
         dateSetting,
         trackerCollectionView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func layoutConstraint() {
        NSLayoutConstraint.activate([
            dateSetting.widthAnchor.constraint(equalToConstant: 120),
            
            searchBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 136),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            trackerCollectionView.topAnchor.constraint(equalTo: searchBar.topAnchor, constant: 74),
            trackerCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            trackerCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            trackerCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // MARK: - Action
    @objc private func dateSettingTapped() {
        currentDate = dateSetting.date
        reloadVisibleCategories(text: searchBar.text, date: currentDate)
    }
    
    @objc private func addTrackerButtonTapped() {
        let vc = TrackerCreator()
        vc.trackerViewController = self
        vc.habitCreationDelegate = self
        present(vc, animated: true, completion: nil)
    }
}

// MARK: - UISearchControllerDelegate, UISearchBarDelegate
extension TrackerViewController: UISearchControllerDelegate, UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        reloadVisibleCategories(text: searchBar.text, date: currentDate)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        reloadVisibleCategories(text: searchBar.text, date: currentDate)
    }
}


extension TrackerViewController: TrackerCollectionDelegate {
    func markTrackerAsCompleted(id: UUID, at indexPath: IndexPath) {
        let selectedDate = dateSetting.date
        let currentDate = Date()
        
        if selectedDate > currentDate {
            return
        }
        
        if let tracker = CoreDataStack.shared.trackerStore.fetchTrackerByID(id: id) {
            if !CoreDataStack.shared.trackerRecordStore.isTrackerCompletedToday(tracker: tracker, date: selectedDate) {
                CoreDataStack.shared.trackerRecordStore.addTrackerRecord(for: tracker, date: selectedDate)
                completedTrackerIds.insert(id)
                if tracker.timetable?.isEmpty ?? true {
                    completedIrregularEvents.insert(id)
                }
                trackerCollectionView.reloadItems(at: [indexPath])
            }
        }
    }
    
    func markTrackerAsUncompleted(id: UUID, at indexPath: IndexPath) {
        let selectedDate = dateSetting.date
        let currentDate = Date()
        
        if selectedDate > currentDate {
            return
        }
        
        if let tracker = CoreDataStack.shared.trackerStore.fetchTrackerByID(id: id) {
            if CoreDataStack.shared.trackerRecordStore.isTrackerCompletedToday(tracker: tracker, date: selectedDate) {
                CoreDataStack.shared.trackerRecordStore.deleteTrackerRecord(for: tracker, date: selectedDate)
                completedTrackerIds.remove(id)
                if tracker.timetable?.isEmpty ?? true {
                    completedIrregularEvents.remove(id)
                }
                trackerCollectionView.reloadItems(at: [indexPath])
            }
        }
    }
    
    private func isTrackerCompleted(id: UUID) -> Bool {
        if let tracker = CoreDataStack.shared.trackerStore.fetchTrackerByID(id: id) {
            return CoreDataStack.shared.trackerRecordStore.isTrackerCompletedToday(tracker: tracker, date: dateSetting.date)
        }
        return false
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let avaliableWidth = trackerCollectionView.bounds.width - params.paddingWidth
        let widthPerItem = avaliableWidth / CGFloat(params.cellCount)
        let heightPerItem = widthPerItem * (148 / 167)
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: 12, left: params.leftInsets, bottom: 16, right: params.rightInsets)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return params.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let header = TrackerHeader()
        header.titleLabel.text = categories[section].headline
        let size = header.systemLayoutSizeFitting(
            CGSize(width: collectionView.frame.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return size
    }
}

// MARK: - UICollectionViewDataSource
extension TrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int
    ) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCollection.cellIdetnifier,
            for: indexPath
        ) as? TrackerCollection else {
            fatalError("Could not cast to TrackersCell")
        }
        
        let cellData = visibleCategories
        let tracker = cellData[indexPath.section].trackers[indexPath.row]
        
        cell.delegate = self
        let isCompletedToday = isTrackerCompletedToday(id: tracker.id)
        let completedDays = completedTrackers.filter {
            $0.id == tracker.id
        }.count
        
        cell.configuration(
            with: tracker,
            isCompletedToday: isCompletedToday,
            completedDays: completedDays,
            indexPath: indexPath
        )
        
        return cell
    }
    
    private func isTrackerCompletedToday(id: UUID) -> Bool {
        completedTrackers.contains { trackerRecord in
            isSameTrackerRecord(trackerRecord: trackerRecord, id: id)
        }
    }
    
    func isSameTrackerRecord(trackerRecord: TrackerRecord, id: UUID) -> Bool {
        let isSameDay = Calendar.current.isDate(trackerRecord.date,
                                                inSameDayAs: dateSetting.date)
        return trackerRecord.id == id && isSameDay
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = trackerCollectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TrackerHeader.headerIdentifier,
                for: indexPath
            ) as? TrackerHeader else {
                assertionFailure("Failed to cast UICollectionReusableView to TrackersHeader")
                return UICollectionReusableView()
            }
            header.titleLabel.text = categories[indexPath.section].headline
            return header
        default:
            assertionFailure("Unexpected element kind")
            return UICollectionReusableView()
        }
    }
}

// MARK: - HabitCreationDelegate
extension TrackerViewController: HabitCreationDelegate {
    func createButtonidTap(tracker: Tracker, category: String) {
        let categoryTitle = category.isEmpty ? "По умолчанию" : category
        
        CoreDataStack.shared.trackerStore.createTracker(
            from: tracker,
            categoryTitle: categoryTitle
        )
        
        reloadVisibleCategories(
            text: searchBar.text,
            date: dateSetting.date
        )
        
        trackerCollectionView.reloadData()
        dismiss(animated: true)
    }
    
    func cancelButtonDidTap() {
        dismiss(animated: true)
    }
}

// MARK: - CoreDataDelegate
extension TrackerViewController: TrackerStoreDelegate {
    func trackerStoreDidChange() {
        reload()
    }
}

extension TrackerViewController: TrackerRecordStoreDelegate {
    func trackerRecordStoreDidChange() {
        completedTrackers = CoreDataStack.shared.trackerRecordStore.fetchAllCompletedTrackers()
        reloadVisibleCategories(text: searchBar.text, date: currentDate)
    }
}

extension TrackerViewController: TrackerCategoryStoreDelegate {
    func trackerCategoryStoreDidChange() {
        reload()
    }
}
