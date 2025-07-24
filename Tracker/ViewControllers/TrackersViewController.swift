import UIKit
import AppMetricaCore

final class TrackersViewController: UIViewController, TrackerRecordStoreDelegate, FiltersViewControllerDelegate {
    func didSelectFilter(_ filter: TrackerFilter) {
        currentFilter = filter
        
        if filter == .today {
            selectedDate = Date()
        }
        
        updateFilteredTrackers()
    }
    
    func storeDidUpdateTrackerRecords(_ store: TrackerRecordStore) {
        filterTrackersForSelectedDate()
        collectionView.reloadData()
    }
    
    //MARK: - Setup TrackersVC
    
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    var selectedDate = Date()
    private var visibleCategories: [TrackerCategory] = []
    private var isDateSelectedByUser = false
    private var currentFilter: TrackerFilter = .all
    var trackerCategories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    private let color = Color()
    
    
    //MARK: - UI Elements
    var upperStackView: UIStackView!
    let mockImageView = UIImageView()
    let mockImageFilter = UIImageView()
    private var collectionView: UICollectionView!
    private let labelTracker: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("tracker_title", comment: "Title for main trackers screen")
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let mockEmptyLabelFilter: UILabel = {
        let label = UILabel()
        label.text = "Ничего не найдено"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let mockEmptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let searchTextField: UISearchTextField = {
        let searchTextField = UISearchTextField()
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.placeholder = "Поиск"
        return searchTextField
    }()
    
    private let filtersButton: UIButton = {
        let button = UIButton(type: .system)
        let title = NSLocalizedString("filters_button", comment:"")
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blueDay
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = color.viewBackgroundColor
        
        setupNavBarLabelAndSearchBar()
        setupImageAndLabelOnTrackerVC()
        setupMockImageAndLabelOnTrackerVC()
        setupCollectionView()
        setupFiltersButton()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        searchTextField.addTarget(self, action: #selector(searchTextChanged(_:)), for: .editingChanged)
        
        setupTapToHideKeyboard()
        selectedDate = Date()
        
        trackerStore.delegate = self
        trackerRecordStore.delegate = self
        
        trackerStore.setupFetchedResultsController()
        trackerRecordStore.setupFetchedResultsController()
        trackerCategoryStore.setupFetchedResultsController()
        trackerStore.debugPrintAllTrackers()
        reloadTrackersFromCoreData()
        filterTrackersForSelectedDate()
        collectionView.reloadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.shared.report(.open(screen: "Main"))
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnalyticsService.shared.report(.close(screen: "Main"))
    }

    
    //MARK: - Functions
    
    private func filterTrackers(for searchText: String) {
        if searchText.isEmpty {
            visibleCategories = trackerCategories
        } else {
            visibleCategories = trackerCategories.compactMap { category in
                let filteredTrackers = category.trackers.filter {
                    $0.name.lowercased().contains(searchText.lowercased())
                }
                return filteredTrackers.isEmpty ? nil : TrackerCategory(name: category.name, trackers: filteredTrackers)
            }
        }
        collectionView.reloadData()
    }
    
    private func filterTrackersForSelectedDate() {
        if !isDateSelectedByUser {
            visibleCategories = trackerCategories
            collectionView.reloadData()
            updatePlaceholderVisibility()
            return
        }
        
        let calendar = Calendar.current
        let weekdayNumber = calendar.component(.weekday, from: selectedDate)
        let weekdayIndex = (weekdayNumber + 5) % 7
        
        guard let todayWeekday = Weekday(rawValue: weekdayIndex) else { return }
        
        let filteredCategories = trackerCategories.compactMap { category in
            let trackersForDay = category.trackers.filter { tracker in
                tracker.schedule.contains(todayWeekday)
            }
            return trackersForDay.isEmpty ? nil : TrackerCategory(name: category.name, trackers: trackersForDay)
        }
        
        visibleCategories = filteredCategories
        collectionView.reloadData()
        updatePlaceholderVisibility()
    }
    
    func updatePlaceholderVisibility() {
        let hasVisibleTrackers = visibleCategories.contains { !$0.trackers.isEmpty }
        let hasAnyTrackers = trackerCategories.contains { !$0.trackers.isEmpty }
        
        switch currentFilter {
        case .all, .today:
            
            mockImageView.isHidden = hasVisibleTrackers
            mockEmptyLabel.isHidden = hasVisibleTrackers
            mockImageFilter.isHidden = true
            mockEmptyLabelFilter.isHidden = true
            
        case .completed, .notCompleted:
            if !hasAnyTrackers {
                mockImageView.isHidden = false
                mockEmptyLabel.isHidden = false
                mockImageFilter.isHidden = true
                mockEmptyLabelFilter.isHidden = true
            } else {
                mockImageView.isHidden = true
                mockEmptyLabel.isHidden = true
                mockImageFilter.isHidden = hasVisibleTrackers
                mockEmptyLabelFilter.isHidden = hasVisibleTrackers
            }
        }
        
        filtersButton.isHidden = !hasAnyTrackers
    }
    
    
    func isFutureDate(_ date: Date) -> Bool {
        return Calendar.current.startOfDay(for: date) > Calendar.current.startOfDay(for: Date())
    }
    
    @objc func addTrackerButtonTapped() {
        AnalyticsService.shared.report(.click(screen: "Main", item: "add_track"))
        let trackerTypeVC = TrackerTypeViewController(trackerStore: trackerStore, trackerCategoryStore: trackerCategoryStore)
        trackerTypeVC.delegate = self
        let navController = UINavigationController(rootViewController: trackerTypeVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
        isDateSelectedByUser = true
        updateFilteredTrackers()
    }
    
    @objc private func filterButtonTapped() {
        AnalyticsService.shared.report(.click(screen: "Main", item: "filter"))
        let filtersVC = FiltersViewController(selectedFilter: currentFilter)
        filtersVC.delegate = self
        let navVC = UINavigationController(rootViewController: filtersVC)
        present(navVC, animated: true)
    }
    
    @objc private func searchTextChanged(_ sender: UISearchTextField) {
        guard let text = sender.text else { return }
        filterTrackers(for: text)
    }
    func reloadTrackersFromCoreData() {
        do {
            let coreDataTrackers = try trackerStore.fetchTrackers()
            var categoriesDict: [String: [Tracker]] = [:]
            
            for coreDataTracker in coreDataTrackers {
                guard
                    let id = coreDataTracker.id,
                    let name = coreDataTracker.name,
                    let emoji = coreDataTracker.emoji,
                    let colorHex = coreDataTracker.color,
                    let color = UIColor.fromHex(colorHex),
                    let scheduleSet = coreDataTracker.schedule as? Set<NSNumber>,
                    let categoryName = coreDataTracker.category?.name
                else {
                    continue
                }
                
                let schedule = scheduleSet.compactMap { Weekday(rawValue: $0.intValue) }
                
                let tracker = Tracker(id: id, name: name, emoji: emoji, color: color, schedule: schedule)
                
                categoriesDict[categoryName, default: []].append(tracker)
            }
            
            trackerCategories = categoriesDict.map {
                TrackerCategory(name: $0.key, trackers: $0.value)
            }
            
            print("Загружено категорий: \(trackerCategories.count)")
        } catch {
            print("Ошибка при загрузке трекеров: \(error)")
        }
        
        filterTrackersForSelectedDate()
        collectionView.reloadData()
        updatePlaceholderVisibility()
        visibleCategories = trackerCategories
    }
    
    func updateFilteredTrackers() {
        var filteredCategories: [TrackerCategory] = []
        
        for category in trackerCategories {
            let filteredTrackers = category.trackers.filter { tracker in
                let isCompleted = trackerRecordStore.isTrackerCompleted(tracker.id, on: selectedDate)
                let isToday = tracker.schedule.contains {
                    let weekday = Calendar.current.component(.weekday, from: selectedDate)
                    return $0.rawValue == (weekday + 5) % 7
                }
                
                switch currentFilter {
                case .all:
                    return true
                case .today:
                    return isToday
                case .completed:
                    return isCompleted
                case .notCompleted:
                    return !isCompleted
                }
            }
            
            if !filteredTrackers.isEmpty {
                filteredCategories.append(TrackerCategory(name: category.name, trackers: filteredTrackers))
            }
        }
        
        visibleCategories = filteredCategories
        collectionView.reloadData()
        updatePlaceholderVisibility()
    }
    
    
    //MARK: - Layout
    
    func setupNavBarLabelAndSearchBar() {
        let addTrackerButton = UIBarButtonItem(
            image: UIImage(named: "add_tracker"),
            style: .plain,
            target: self,
            action: #selector(addTrackerButtonTapped))
        addTrackerButton.tintColor = .blackDay
        navigationItem.leftBarButtonItem = addTrackerButton
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.tintColor = .blackDay
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        let datePickerItem = UIBarButtonItem(customView: datePicker)
        navigationItem.rightBarButtonItem = datePickerItem
        
        view.addSubview(labelTracker)
        view.addSubview(searchTextField)
        
        NSLayoutConstraint.activate([
            labelTracker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            labelTracker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            labelTracker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            searchTextField.topAnchor.constraint(equalTo: labelTracker.bottomAnchor, constant: 8),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchTextField.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 7
        layout.sectionInset = UIEdgeInsets(top: 8, left: 16, bottom: 0, right: 16)
        layout.headerReferenceSize = CGSize(width: view.bounds.width, height: 30)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.systemBackground
        
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        collectionView.register(CategoryHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategoryHeaderView.identifier)
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        view.bringSubviewToFront(mockImageView)
        view.bringSubviewToFront(mockEmptyLabel)
        view.bringSubviewToFront(mockImageFilter)
        view.bringSubviewToFront(mockEmptyLabelFilter)
    }
    
    private func setupTapToHideKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    func setupImageAndLabelOnTrackerVC() {
        let image = UIImage(named: "mock_star")
        mockImageView.image = image
        mockImageView.contentMode = .scaleAspectFit
        view.addSubview(mockImageView)
        mockImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mockImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mockImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        view.addSubview(mockEmptyLabel)
        NSLayoutConstraint.activate([
            mockEmptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mockEmptyLabel.topAnchor.constraint(equalTo: mockImageView.bottomAnchor, constant: 8)
        ])
    }
    
    func setupMockImageAndLabelOnTrackerVC() {
        let image = UIImage(named: "error_emoji")
        mockImageFilter.image = image
        mockImageFilter.contentMode = .scaleAspectFit
        view.addSubview(mockImageFilter)
        mockImageFilter.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mockImageFilter.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mockImageFilter.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        view.addSubview(mockEmptyLabelFilter)
        NSLayoutConstraint.activate([
            mockEmptyLabelFilter.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mockEmptyLabelFilter.topAnchor.constraint(equalTo: mockImageFilter.bottomAnchor, constant: 8)
        ])
    }
    private func setupFiltersButton() {
        view.addSubview(filtersButton)
        filtersButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filtersButton.widthAnchor.constraint(equalToConstant: 114),
            filtersButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        collectionView.contentInset.bottom = 80
    }
}

//MARK: - UIColectionViewDataSource, UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        let isCompleted = trackerRecordStore.isTrackerCompleted(tracker.id, on: selectedDate)
        let completedDays = trackerRecordStore.completedDaysCount(for: tracker.id)
        cell.configure(with: tracker, completedDays: completedDays, isCompleted: isCompleted)
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: CategoryHeaderView.identifier,
            for: indexPath
        ) as? CategoryHeaderView else {
            return UICollectionReusableView()
        }
        
        let category = visibleCategories[indexPath.section]
        header.configure(with: category.name)
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width - 16 * 2 - 7
        let cellWidth = availableWidth / 2
        return CGSize(width: cellWidth, height: 148)
    }
    
    private func trackerAt(_ indexPath: IndexPath) -> Tracker {
        return visibleCategories[indexPath.section].trackers[indexPath.item]
    }
}

//MARK: - CreateTrackerVCDelegate

extension TrackersViewController: CreateTrackerViewControllerDelegate {
    func didCreateTracker(_ tracker: Tracker, in category: String) {
        if let index = trackerCategories.firstIndex(where: { $0.name == category }) {
            trackerCategories[index].trackers.append(tracker)
        } else {
            trackerCategories.append(TrackerCategory(name: category, trackers: [tracker]))
        }
        
        collectionView.reloadData()
        updatePlaceholderVisibility()
        filterTrackersForSelectedDate()
        reloadTrackersFromCoreData()
    }
}

//MARK: - TrackerCellDelegate

extension TrackersViewController: TrackerCellDelegate {
    
    func trackerCellDidTapComplete(_ cell: TrackerCell) {
        
        AnalyticsService.shared.report(.click(screen: "Main", item: "track"))
        
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        
        if isFutureDate(selectedDate) {
            return
        }
        if trackerRecordStore.isTrackerCompleted(tracker.id, on: selectedDate) {
            trackerRecordStore.removeRecord(for: tracker.id, on: selectedDate)
        } else {
            do {
                try trackerRecordStore.addTrackerRecord(with: tracker.id, on: selectedDate)
            } catch {
                print("\(error)")
            }
        }
        collectionView.reloadItems(at: [indexPath])
        filterTrackersForSelectedDate()
    }
    
    func trackerCellDidRequestEdit(_ cell: TrackerCell) {
        AnalyticsService.shared.report(.click(screen: "Main", item: "edit"))
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let tracker = trackerAt(indexPath)
        
        guard let trackerCoreData = trackerStore.trackerCoreData(with: tracker.id) else {
            print("Не удалось найти TrackerCoreData для id: \(tracker.id)")
            return
        }
        
        let createTrackerVC = CreateTrackerViewController(
            trackerStore: trackerStore,
            trackerCategoryStore: trackerCategoryStore,
            trackerToEdit: trackerCoreData
        )
        createTrackerVC.delegate = self
        
        let navController = UINavigationController(rootViewController: createTrackerVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
    }
    
    func trackerCellDidRequestDelete(_ cell: TrackerCell) {
        
        AnalyticsService.shared.report(.click(screen: "Main", item: "delete"))
        
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let tracker = trackerAt(indexPath)
        
        let alert = UIAlertController(
            title: "",
            message: "Уверены что хотите удалить трекер?",
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.trackerStore.deleteTracker(withId: tracker.id)
            self?.reloadTrackersFromCoreData()
            self?.updatePlaceholderVisibility()
            self?.collectionView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

//MARK: - TrackerStoreDelegate

extension TrackersViewController: TrackerStoreDelegate {
    func storeDidUpdateTrackersStore(_ store: TrackerStore) {
        print("storeDidUpdateTrackersStore called")
        reloadTrackersFromCoreData()
        updatePlaceholderVisibility()
        collectionView.reloadData()
    }
}

