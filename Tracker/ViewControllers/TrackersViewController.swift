import Foundation
import UIKit

final class TrackersViewController: UIViewController {
    
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    
    let imageView = UIImageView()
    
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
        searchBar.placeholder = "Поиск"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.heightAnchor.constraint(equalToConstant: 36).isActive = true
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = .clear
        return searchBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNavigationBar()
        setupUIStackView()
        setupImageAndLabelOnTrackerVC()
    }
    
    func setupNavigationBar() {
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
    
    func setupUIStackView() {
        
        let spacer1 = UIView()
        spacer1.translatesAutoresizingMaskIntoConstraints = false
        spacer1.heightAnchor.constraint(equalToConstant: 7).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [labelTracker, spacer1, searchBar])
        
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo:
                                                    view.trailingAnchor, constant: -16)
        ])
    }
    
    @objc func addTrackerButtonTapped() {
        let trackerTypeVC = TrackerTypeViewController()
        let navController = UINavigationController(rootViewController: trackerTypeVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
    }
}

