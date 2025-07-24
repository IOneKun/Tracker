import UIKit

protocol FiltersViewControllerDelegate: AnyObject {
    func didSelectFilter(_ filter: TrackerFilter)
}

final class FiltersViewController: UIViewController {
    
    weak var delegate: FiltersViewControllerDelegate?
    private var selectedFilter: TrackerFilter?
    
    // MARK: - UI Elements
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(FilterCell.self, forCellReuseIdentifier: FilterCell.reuseIdentifier)
        table.backgroundColor = .grayDay
        table.layer.cornerRadius = 16
        table.layer.masksToBounds = true
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        table.isScrollEnabled = false
        table.tableFooterView = UIView()
        return table
    }()
    
    // MARK: - Init
    
    init(selectedFilter: TrackerFilter?) {
        self.selectedFilter = selectedFilter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "Фильтры"
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(TrackerFilter.allCases.count * 75))
        ])
        
        tableView.dataSource = self
        tableView.delegate = self
    }
}

// MARK: - TableView DataSource & Delegate

extension FiltersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TrackerFilter.allCases.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let filter = TrackerFilter.allCases[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FilterCell.reuseIdentifier, for: indexPath) as? FilterCell else {
            return UITableViewCell()
        }
        
        let shouldShowCheckmark = (filter == .completed || filter == .notCompleted)
        let isSelected = (filter == selectedFilter) && shouldShowCheckmark
        cell.configure(with: filter.rawValue, isSelected: isSelected)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chosenFilter = TrackerFilter.allCases[indexPath.row]
        delegate?.didSelectFilter(chosenFilter)
        dismiss(animated: true)
    }
}

