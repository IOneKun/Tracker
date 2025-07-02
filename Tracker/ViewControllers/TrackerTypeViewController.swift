import Foundation
import UIKit

final class TrackerTypeViewController: UIViewController {
    
    weak var delegate: CreateTrackerViewControllerDelegate?
    private let trackerStore: TrackerStore
    private let trackerCategoryStore: TrackerCategoryStore
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "Создание трекера"
        setupUITrackerTypeVC()
    }
    init(trackerStore: TrackerStore, trackerCategoryStore: TrackerCategoryStore) {
        self.trackerStore = trackerStore
        self.trackerCategoryStore = trackerCategoryStore
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Functions
    
    func showCreateTracker() {
        let createTrackerVC = CreateTrackerViewController(
            trackerStore: trackerStore, trackerCategoryStore: trackerCategoryStore)
        createTrackerVC.delegate = delegate
        navigationController?.pushViewController(createTrackerVC, animated: true)
    }
    @objc func habitButtonTapped() {
        let createVC = CreateTrackerViewController(
            trackerStore: trackerStore,
            trackerCategoryStore: trackerCategoryStore
        )
        createVC.delegate = delegate
        createVC.trackerType = .habit
        let navController = UINavigationController(rootViewController: createVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
    }
    
    @objc func irregularButtonTapped() {
        let createVC = CreateTrackerViewController(
            trackerStore: trackerStore,
            trackerCategoryStore: trackerCategoryStore
        )
        createVC.delegate = delegate
        createVC.trackerType = .irregularEvent
        
        let navController = UINavigationController(rootViewController: createVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
    }
    
    //MARK: - Setup UI
    
    func setupUITrackerTypeVC() {
        
        let habitButton = UIButton(type: .system)
        habitButton.backgroundColor = UIColor(named: "blackDay")
        habitButton.tintColor = .white
        habitButton.setTitle(NSLocalizedString("Привычка", comment: ""), for: .normal)
        habitButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        habitButton.layer.cornerRadius = 16
        habitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(habitButton)
        
        habitButton.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            habitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            habitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            habitButton.widthAnchor.constraint(equalToConstant: 335),
            habitButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        let irregularButton = UIButton(type: .system)
        irregularButton.backgroundColor = UIColor(named: "blackDay")
        irregularButton.tintColor = .white
        irregularButton.setTitle(NSLocalizedString("Нерегулярное событие", comment: ""), for: .normal)
        irregularButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        irregularButton.layer.cornerRadius = 16
        irregularButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(irregularButton)
        
        irregularButton.addTarget(self, action: #selector(irregularButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            irregularButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            irregularButton.widthAnchor.constraint(equalToConstant: 335),
            irregularButton.heightAnchor.constraint(equalToConstant: 60),
            irregularButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16)
        ])
    }
}
