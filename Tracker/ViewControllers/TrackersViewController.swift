import Foundation
import UIKit

final class TrackersViewController: UIViewController, CreateTrackerViewControllerDelegate {
    
    func didCreateTracker(_ tracker: Tracker, in category: String) {
        if let index = trackerCategories.firstIndex(where: { $0.name == category }) {
            trackerCategories[index].trackers.append(tracker)
        } else {
            trackerCategories.append(TrackerCategory(name: category, trackers: [tracker]))
        }

        collectionView.reloadData()
        updatePlaceholderVisibility()
    }
    
    var trackerCategories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    
    var upperStackView: UIStackView!
    let imageView = UIImageView()
    private var collectionView: UICollectionView!
    private let labelTracker: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emptyLabel: UILabel = {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNavBarLabelAndSearchBar()
        setupImageAndLabelOnTrackerVC()
        setupCollectionView()
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func updatePlaceholderVisibility() {
        let hasTrackers = trackerCategories.contains { !$0.trackers.isEmpty }
        imageView.isHidden = hasTrackers
        emptyLabel.isHidden = hasTrackers
    }
    
    func setupNavBarLabelAndSearchBar() {
        let addTrackerButton = UIBarButtonItem(
            image: UIImage(named: "add_tracker"),
            style: .plain,
            target: self,
            action: #selector(addTrackerButtonTapped))
        addTrackerButton.tintColor = .blackDay
        navigationItem.leftBarButtonItem = addTrackerButton
        
        let dateButton = UIButton()
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let formattedDate = formatter.string(from: currentDate)
        
        dateButton.setTitle(formattedDate, for: .normal)
        dateButton.backgroundColor = .ypGrey
        dateButton.setTitleColor(.blackDay, for: .normal)
        dateButton.layer.cornerRadius = 8
        dateButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 5.5, bottom: 6, right: 5.5 )
        
        let dateBarItem = UIBarButtonItem(customView: dateButton)
        navigationItem.rightBarButtonItem = dateBarItem
        
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
        layout.minimumInteritemSpacing = 9
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
    }
    
    func setupImageAndLabelOnTrackerVC() {
        let image = UIImage(named: "mock_star")
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        view.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8)
        ])
    }
    
    @objc func addTrackerButtonTapped() {
        let trackerTypeVC = TrackerTypeViewController()
        trackerTypeVC.delegate = self
        let navController = UINavigationController(rootViewController: trackerTypeVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
    }
}
extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return trackerCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trackerCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        let tracker = trackerCategories[indexPath.section].trackers[indexPath.item]
        cell.configure(with: tracker, completedDays: 0)
        
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
        
        let category = trackerCategories[indexPath.section]
        header.configure(with: category.name)
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width - 16 * 2 - 9
        let cellWidth = availableWidth / 2
        return CGSize(width: cellWidth, height: 148)
    }
}

