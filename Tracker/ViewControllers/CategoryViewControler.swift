import UIKit

protocol CategoryViewControllerDelegate: AnyObject {
    func didSelectCategory(_ category: String)
}

final class CategoryViewController: UIViewController {
    
    weak var delegate: CategoryViewControllerDelegate?
    
    private var tableViewHeightConstraint: NSLayoutConstraint?
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    private var categories: [String] = []
    private var selectedCategory: String?
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reuseIdentifier)
        table.layer.masksToBounds = true
        table.layer.cornerRadius = 16
        table.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        table.backgroundColor = .grayDay
        table.isScrollEnabled = false
        return table
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "mock_star"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно\nобъединить по смыслу"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blackDay
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Категория"
        view.backgroundColor = .white
        
        tableView.delegate = self
        tableView.dataSource = self
        addButton.addTarget(self, action: #selector(addCategoryTapped), for: .touchUpInside)
        
        
        setupLayout()
        updateUI()
    }
    
    // MARK: - Layout
    
    private func setupLayout() {
           scrollView.translatesAutoresizingMaskIntoConstraints = false
           stackView.translatesAutoresizingMaskIntoConstraints = false
           stackView.axis = .vertical
           stackView.spacing = 16
           
           view.addSubview(scrollView)
           view.addSubview(addButton)
           scrollView.addSubview(stackView)
           
           stackView.addArrangedSubview(tableView)
           
           NSLayoutConstraint.activate([
               scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
               scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
               scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
               scrollView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -16),
               
               stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
               stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
               stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
               stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
               stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),
               
               addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
               addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
               addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
               addButton.heightAnchor.constraint(equalToConstant: 60)
           ])
           
           tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: CGFloat(categories.count * 75))
           tableViewHeightConstraint?.isActive = true
       }
    
    private func updateUI() {
        let shouldHideEmptyState = !categories.isEmpty
        imageView.isHidden = shouldHideEmptyState
        emptyLabel.isHidden = shouldHideEmptyState
        tableView.isHidden = !shouldHideEmptyState
    }
    
    // MARK: - Actions
    
    @objc private func addCategoryTapped() {
        let createVC = CreateCategoryViewController()
        createVC.delegate = self
        let navVC = UINavigationController(rootViewController: createVC)
        present(navVC, animated: true)
    }
}

// MARK: - TableView

extension CategoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryCell.reuseIdentifier,
            for: indexPath
        ) as? CategoryCell else { return UITableViewCell() }
        
        let category = categories[indexPath.row]
        let isSelected = category == selectedCategory
        cell.configure(with: category, isSelected: isSelected)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCategory = categories[indexPath.row]
        delegate?.didSelectCategory(selectedCategory!)
        tableView.reloadData()
    }
    
}

// MARK: - CreateCategoryViewControllerDelegate

extension CategoryViewController: CreateCategoryViewControllerDelegate {
    func didCreateCategory(_ category: String) {
      
        categories.append(category)
        let newHeight = CGFloat(categories.count * 75)
          tableViewHeightConstraint?.constant = newHeight
        updateUI()
        tableView.reloadData()
    }
}

