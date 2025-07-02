import UIKit

final class TrackersViewController: UIViewController, TrackerRecordStoreDelegate {
    func storeDidUpdateTrackerRecords(_ store: TrackerRecordStore) {
        filterTrackersForSelectedDate()
        collectionView.reloadData()
    }
    
    //MARK: - Setup TrackersVC
    
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    private var selectedDate = Date()
    private var visibleCategories: [TrackerCategory] = []
    private var isDateSelectedByUser = false
    var trackerCategories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    
    //MARK: - UI Elements
    var upperStackView: UIStackView!
    let mockImageView = UIImageView()
    private var collectionView: UICollectionView!
    private let labelTracker: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = .systemFont(ofSize: 34, weight: .bold)
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
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Поиск"
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .clear
        searchBar.searchTextField.backgroundColor = UIColor.systemGray6
        searchBar.searchTextField.layer.cornerRadius = 10
        searchBar.searchTextField.layer.masksToBounds = true
        return searchBar
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNavBarLabelAndSearchBar()
        setupImageAndLabelOnTrackerVC()
        setupCollectionView()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        searchBar.delegate = self
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
    
    //MARK: - Functions
    
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
        let hasTrackers = visibleCategories.contains { !$0.trackers.isEmpty }
        mockImageView.isHidden = hasTrackers
        mockEmptyLabel.isHidden = hasTrackers
    }
    func isFutureDate(_ date: Date) -> Bool {
        return Calendar.current.startOfDay(for: date) > Calendar.current.startOfDay(for: Date())
    }
    
    @objc func addTrackerButtonTapped() {
        let trackerTypeVC = TrackerTypeViewController(trackerStore: trackerStore, trackerCategoryStore: trackerCategoryStore)
        trackerTypeVC.delegate = self
        let navController = UINavigationController(rootViewController: trackerTypeVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
    }
    @objc private func dateChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
        isDateSelectedByUser = true
        filterTrackersForSelectedDate()
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
        view.addSubview(searchBar)
        
        NSLayoutConstraint.activate([
            labelTracker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            labelTracker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            labelTracker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            searchBar.topAnchor.constraint(equalTo: labelTracker.bottomAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchBar.heightAnchor.constraint(equalToConstant: 36)
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
        collectionView.backgroundColor = .white
        
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        collectionView.register(CategoryHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategoryHeaderView.identifier)
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        view.bringSubviewToFront(mockImageView)
        view.bringSubviewToFront(mockEmptyLabel)
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
}

//MARK: - UIColectionViewDataSource, UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
}

//MARK: - UISearchBarDelegate

extension TrackersViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
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

