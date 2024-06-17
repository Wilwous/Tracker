//
//  ViewController.swift
//  Tracker
//
//  Created by Антон Павлов on 17.01.2024.
//

import UIKit

final class TrackerViewController: UIViewController {
    
    // MARK: - Private Properties
    private var currentDate: Date = Date()
    private var params: GeometricParams
    
    private var categories: [TrackerCategory] = []
    private var filteredCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    
    private var completedIrregularEvents: Set<UUID> = []
    private var trackerCreationDates: [UUID: Date] = [:]
    
    private var isSearching = false
    private var hasTrackersForSelectedDate: Bool = false
    private var selectedFilter: TrackerFilterHelper = .all
    
    // MARK: - UI Components
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
        
        let datePickerItem = UIBarButtonItem(customView: datePicker)
        navigationItem.rightBarButtonItem = datePickerItem
        
        datePicker.addTarget(
            self,
            action: #selector(dateSettingTapped),
            for: .valueChanged
        )
        
        return datePicker
    }()
    
    private lazy var trackerCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        let collectionView = UICollectionView(
            frame: .zero, collectionViewLayout: layout
        )
        collectionView.backgroundColor = .ypWhite
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
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
    
    private lazy var filterButton: UIButton =  {
        let filter = UIButton(type: .system)
        filter.setTitle(
            LocalizationHelper.localizedString("filtres"),
            for: .normal
        )
        filter.backgroundColor = .ypBlue
        filter.setTitleColor(.ypWhite, for: .normal)
        filter.layer.cornerRadius = 16
        filter.addTarget(
            self,
            action: #selector(filterButtonTapped),
            for: .touchUpInside
        )
        
        updateFilterButtonVisibility()
        
        return filter
    }()
    
    // MARK: - Initialization
    init() {
        self.params = GeometricParams(
            cellCount: 2, leftInsets: 16,
            rightInsets: 16, cellSpacing: 9
        )
        super.init(nibName: nil, bundle: nil)
        CoreDataStack.shared.trackerStore.delegate = self
        CoreDataStack.shared.trackerRecordStore.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        currentDate = Date()
        dateSetting.date = currentDate
        applyFilter(selectedFilter)
        filterAndReloadCategories(text: searchBar.text, date: dateSetting.date)
        addElements()
        layoutConstraint()
        settingNavigationBar()
        reload()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.didOpenMain()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnalyticsService.didCloseMain()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            view.backgroundColor = UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ? .black : .white
            }
            updateDatePickerAppearance(dateSetting)
            updateSearchBarAppearance(searchBar)
            settingNavigationBar()
            trackerCollectionView.backgroundColor = UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ? .black : .white
            }
        }
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
        
        filterAndReloadCategories(text: searchBar.text, date: dateSetting.date)
        trackerCollectionView.reloadData()
    }
    
    // MARK: - Filter
    func filterAndReloadCategories(text: String?, date: Date) {
        let filterText = (text ?? "").lowercased()
        let filterWeekday = WeekDay.from(date: date)
        
        let textFilteredCategories = categories.compactMap { category -> TrackerCategory? in
            let filteredTrackers = category.trackers.filter { tracker in
                filterText.isEmpty || tracker.name.lowercased().contains(filterText)
            }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(
                headline: category.headline, trackers: filteredTrackers
            )
        }
        
        if let filterWeekday = filterWeekday {
            filteredCategories = textFilteredCategories.compactMap { category -> TrackerCategory? in
                let filteredTrackers = category.trackers.filter { tracker in
                    guard let trackerCoreData = CoreDataStack.shared.trackerStore.convertToCoreData(
                        tracker: tracker
                    ) else {
                        return false
                    }
                    let isCompletedToday = CoreDataStack.shared.trackerRecordStore.isTrackerCompletedTodayStore(
                        tracker: trackerCoreData, date: date
                    )
                    let matchesFilter: Bool
                    switch selectedFilter {
                    case .completed:
                        matchesFilter = isCompletedToday
                    case .uncompleted:
                        matchesFilter = !isCompletedToday
                    case .today, .all:
                        matchesFilter = true
                    }
                    
                    if !matchesFilter {
                        return false
                    }
                    
                    if tracker.timetable?.isEmpty ?? true {
                        if let creationDate = trackerCreationDates[tracker.id],
                           Calendar.current.isDate(creationDate, inSameDayAs: date) {
                            return !completedIrregularEvents.contains(tracker.id)
                        } else {
                            return false
                        }
                    }
                    return tracker.timetable!.contains(filterWeekday)
                }
                return filteredTrackers.isEmpty ? nil : TrackerCategory(
                    headline: category.headline, trackers: filteredTrackers
                )
            }
        } else {
            filteredCategories = textFilteredCategories
        }
        updateCategoriesView()
        updateFilterButtonVisibility()
        trackerCollectionView.reloadData()
    }
    
    private func updateFilterButtonVisibility() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let hasTrackersForSelectedDate = self.categories.flatMap { $0.trackers }.contains { tracker in
                if let timetable = tracker.timetable, !timetable.isEmpty {
                    return timetable.contains { $0 == WeekDay.from(date: self.dateSetting.date) }
                } else if let creationDate = self.trackerCreationDates[tracker.id] {
                    return Calendar.current.isDate(creationDate, inSameDayAs: self.dateSetting.date)
                }
                return false
            }
            
            let noResults = self.filteredCategories.isEmpty && self.isSearching
            
            if noResults && hasTrackersForSelectedDate {
                self.trackersViewStubs.isHidden = false
                self.trackersViewStubs.configure(with: .noResults, labelHeight: 20)
                self.filterButton.isHidden = false
            } else if !hasTrackersForSelectedDate {
                self.trackersViewStubs.isHidden = false
                self.trackersViewStubs.configure(with: .noTrackers, labelHeight: 20)
                self.filterButton.isHidden = true
            } else {
                self.trackersViewStubs.isHidden = false
                self.trackersViewStubs.configure(with: .noResults, labelHeight: 20)
                self.filterButton.isHidden = false
            }
            
            self.trackerCollectionView.backgroundView = self.filteredCategories.isEmpty ? self.trackersViewStubs : nil
        }
    }
    
    private func applyFilter(_ filter: TrackerFilterHelper) {
        selectedFilter = filter
        
        if filter == .today {
            currentDate = Date()
            dateSetting.date = currentDate
        }
        filterAndReloadCategories(text: searchBar.text, date: dateSetting.date)
        updateFilterButtonAppearance()
    }
    
    private func updateFilterButtonAppearance() {
        if selectedFilter == .all {
            filterButton.setTitleColor(.ypWhite, for: .normal)
            filterButton.setTitle("\(LocalizationHelper.localizedString("filtres"))", for: .normal)
        } else {
            filterButton.backgroundColor = .ypBlue
            filterButton.setTitle("\(LocalizationHelper.localizedString("filtres")) ❇️", for: .normal)
        }
    }
    
    private func updateCategoriesView() {
        trackersViewStubs.isHidden = !filteredCategories.isEmpty
        trackerCollectionView.backgroundView = filteredCategories.isEmpty ? trackersViewStubs : nil
    }
    
    // MARK: - ContextMenu
    func isTrackerPinned(_ tracker: Tracker) -> Bool {
        guard let trackerCoreData = CoreDataStack.shared.trackerStore.fetchTracker(
            by: tracker.id) else { return false }
        return trackerCoreData.category?.title == "Закрепленные"
    }
    
    func pinTracker(_ tracker: Tracker) {
        CoreDataStack.shared.trackerStore.pinTracker(tracker.id)
        reload()
    }
    
    func unpinTracker(_ tracker: Tracker) {
        CoreDataStack.shared.trackerStore.unpinTracker(tracker.id)
        reload()
    }
    
    func togglePinTracker(tracker: Tracker, at indexPath: IndexPath) {
        if isTrackerPinned(tracker) {
            unpinTracker(tracker)
        } else {
            pinTracker(tracker)
        }
        trackerCollectionView.reloadData()
    }
    
    func deleteTracker(trackerId: UUID) {
        CoreDataStack.shared.trackerStore.deleteTracker(trackerId: trackerId)
        reload()
    }
    
    // MARK: - Editing
    func editTracker(_ tracker: Tracker) {
        let editHabitVC = HabitCreation(isHabit: true, isEditing: true, existingTracker: tracker)
        editHabitVC.habitCreationDelegate = self
        editHabitVC.modalPresentationStyle = .pageSheet
        present(editHabitVC, animated: true)
    }
    
    func handleEditTracker(tracker: Tracker) {
        editTracker(tracker)
    }
    
    // MARK: - Setup View
    private func settingNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        title = LocalizationHelper.localizedString("trackers")
        
        let addTrackerButton = UIButton(type: .custom)
        addTrackerButton.imageEdgeInsets = UIEdgeInsets(
            top: 0, left: -20, bottom: 0, right: 0
        )
        
        addTrackerButton.addTarget(
            self,
            action: #selector(addTrackerButtonTapped),
            for: .touchUpInside
        )
        
        let addTrackerButtonItem = UIBarButtonItem(customView: addTrackerButton)
        navigationItem.leftBarButtonItem = addTrackerButtonItem
        
        let addTrackerImage = UIImage(
            named: traitCollection.userInterfaceStyle == .dark ? "addTrackerDarkMode" :
                "addTracker")?.withRenderingMode(.alwaysOriginal
                )
        addTrackerButton.setImage(addTrackerImage, for: .normal)
    }
    
    private func updateDatePickerAppearance(_ datePicker: UIDatePicker) {
        if traitCollection.userInterfaceStyle == .dark {
            datePicker.overrideUserInterfaceStyle = .light
            datePicker.backgroundColor = UIColor.ypLightGray
            datePicker.layer.cornerRadius = 8
            datePicker.layer.masksToBounds = true
            
            let textFieldInsideDatePicker = (
                datePicker.subviews[0].subviews[0].subviews[0] as? UITextField
            )
            textFieldInsideDatePicker?.textColor = UIColor.black
        } else {
            datePicker.overrideUserInterfaceStyle = .unspecified
            datePicker.backgroundColor = nil
            datePicker.layer.cornerRadius = 0
        }
    }
    
    private func updateSearchBarAppearance(_ searchBar: UISearchBar) {
        searchBar.barStyle = traitCollection.userInterfaceStyle == .dark ? .black : .default
        searchBar.searchTextField.textColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .white : .black
        }
        searchBar.searchTextField.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .darkGray : .white
        }
    }
    
    // MARK: - Setup View
    private func addElements() {
        [searchBar,
         dateSetting,
         trackerCollectionView,
         filterButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func layoutConstraint() {
        NSLayoutConstraint.activate([
            dateSetting.widthAnchor.constraint(equalToConstant: 110),
            
            searchBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 136),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            trackerCollectionView.topAnchor.constraint(equalTo: searchBar.topAnchor, constant: 74),
            trackerCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            trackerCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            trackerCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Action
    @objc private func dateSettingTapped() {
        currentDate = dateSetting.date
        filterAndReloadCategories(text: searchBar.text, date: currentDate)
    }
    
    @objc private func addTrackerButtonTapped() {
        AnalyticsService.didClickAddTrack()
        let vc = TrackerCreator()
        vc.trackerViewController = self
        vc.habitCreationDelegate = self
        present(vc, animated: true, completion: nil)
    }
    
    // MARK: - Filter
    @objc private func filterButtonTapped() {
        AnalyticsService.didClickFilter()
        let filtersVC = FiltersViewController()
        filtersVC.selectedFilter = selectedFilter
        filtersVC.modalPresentationStyle = .pageSheet
        filtersVC.onSelectFilter = { [weak self] filter in
            self?.selectedFilter = filter
            self?.applyFilter(filter)
            self?.dismiss(animated: false, completion: nil)
        }
        present(filtersVC, animated: true)
    }
}

// MARK: - UISearchControllerDelegate, UISearchBarDelegate
extension TrackerViewController: UISearchControllerDelegate, UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterAndReloadCategories(text: searchBar.text, date: currentDate)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        filterAndReloadCategories(text: searchBar.text, date: currentDate)
    }
}

// MARK: - TrackerCollectionDelegate
extension TrackerViewController: TrackerCollectionDelegate {
    func markTrackerAsCompleted(id: UUID, at indexPath: IndexPath) {
        AnalyticsService.didClickTrack()
        let selectedDate = dateSetting.date
        let currentDate = Date()
        
        if selectedDate > currentDate {
            return
        }
        
        if let tracker = CoreDataStack.shared.trackerStore.fetchTracker(by: id) {
            CoreDataStack.shared.trackerRecordStore.addTrackerRecord(for: tracker, date: selectedDate)
            if tracker.timetable?.isEmpty ?? true {
                completedIrregularEvents.insert(id)
            }
            trackerCollectionView.reloadItems(at: [indexPath])
        }
    }
    
    func markTrackerAsUncompleted(id: UUID, at indexPath: IndexPath) {
        let selectedDate = dateSetting.date
        let currentDate = Date()
        
        if selectedDate > currentDate {
            return
        }
        
        if let tracker = CoreDataStack.shared.trackerStore.fetchTracker(by: id) {
            CoreDataStack.shared.trackerRecordStore.deleteTrackerRecord(for: tracker, date: selectedDate)
            if tracker.timetable?.isEmpty ?? true {
                completedIrregularEvents.remove(id)
            }
            trackerCollectionView.reloadItems(at: [indexPath])
        }
    }
    
    private func isTrackerCompletedToday(id: UUID) -> Bool {
        if let tracker = CoreDataStack.shared.trackerStore.fetchTracker(by: id) {
            return CoreDataStack.shared.trackerRecordStore.isTrackerCompletedTodayStore(
                tracker: tracker, date: dateSetting.date
            )
        }
        return false
    }
    
    private func completedDaysCount(for trackerID: UUID) -> Int {
        if let tracker = CoreDataStack.shared.trackerStore.fetchTracker(by: trackerID) {
            return CoreDataStack.shared.trackerRecordStore.completedDaysCountStore(for: tracker)
        }
        return 0
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
            CGSize(width: collectionView.frame.width,
                   height: UIView.layoutFittingCompressedSize.height
                  ),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return size
    }
}

// MARK: - UICollectionViewDataSource
extension TrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int
    ) -> Int {
        return filteredCategories[section].trackers.count
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
        
        let cellData = filteredCategories
        let tracker = cellData[indexPath.section].trackers[indexPath.row]
        
        cell.delegate = self
        let isCompletedToday = isTrackerCompletedToday(id: tracker.id)
        let completedDays = completedDaysCount(for: tracker.id)
        
        cell.configuration(
            with: tracker,
            isCompletedToday: isCompletedToday,
            completedDays: completedDays,
            indexPath: indexPath,
            isPinned: isTrackerPinned(tracker)
        )
        
        cell.onEdit = { [weak self] in
            guard let self = self else { return }
            let category = self.filteredCategories[indexPath.section]
            let tracker = category.trackers[indexPath.row]
            let editHabitVC = HabitCreation(
                isHabit: true,
                isEditing: true,
                existingTracker: tracker
            )
            editHabitVC.habitCreationDelegate = self
            editHabitVC.modalPresentationStyle = .pageSheet
            self.present(editHabitVC, animated: true)
        }
        
        cell.onDelete = { [weak self] in
            let alert = UIAlertController(
                title: LocalizationHelper.localizedString("trackerRemovalAlert"),
                message: nil, preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(
                title: LocalizationHelper.localizedString("delete"),
                style: .destructive
            ) { [weak self] _ in
                guard let self = self else { return }
                let tracker = self.filteredCategories[indexPath.section].trackers[indexPath.row]
                self.deleteTracker(trackerId: tracker.id)
            }
            
            let cancelAction = UIAlertAction(
                title: LocalizationHelper.localizedString("cancel"), style: .cancel
            )
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            self?.present(alert, animated: true)
        }
        
        cell.onPin = { [weak self] in
            self?.togglePinTracker(tracker: tracker, at: indexPath)
        }
        
        return cell
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
        
        filterAndReloadCategories(
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
    func trackerStoreDidAddTracker(_ tracker: TrackerCoreData) {
        reload()
    }
    
    func trackerStoreDidChange() {
        reload()
    }
}

extension TrackerViewController: TrackerRecordStoreDelegate {
    func trackerRecordStoreDidChange() {
        reload()
    }
}
