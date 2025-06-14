import UIKit

protocol CreateTrackerViewControllerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker)
}

final class CreateTrackerViewController: UIViewController, ScheduleViewControllerDelegate {
    
    func didSelectDays(_ days: [Weekday]) {
        self.selectedSchedule = days
        updateScheduleOptionText()
    }
    
    weak var delegate: CreateTrackerViewControllerDelegate?
    
    private var selectedSchedule: [Weekday] = []
    private var categories: [TrackerCategory] = []
    private let textFieldView = TrackerTextFieldView()
    private let buttonsView = ActionButtonsView()
    private let options: [TrackerOptionType] = TrackerOptionType.allCases
    private lazy var optionsTableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        table.register(TrackerOptionCell.self, forCellReuseIdentifier: TrackerOptionCell.reuseIdentifier)
        table.separatorStyle = .singleLine
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        table.isScrollEnabled = false
        table.backgroundColor = .grayDay
        table.layer.cornerRadius = 16
        return table
    }()
    private let emojis = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"]
    private let colors: [UIColor] = [.color1, .color2, .color3, .color4, .color5, .color6, .color7, .color8, .color9, .color10, .color11, .color12, .color13, .color14, .color15, .color16, .color17, .color18]
    private var selectedEmojiIndex: IndexPath?
    private var selectedColorIndex: IndexPath?
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.text = "Emoji"
        label.font = .systemFont(ofSize: 19, weight: .bold)
        return label
    }()
    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.reuseId)
        return collectionView
    }()
    private lazy var colorLabel: UILabel = {
        let label = UILabel()
        label.text = "Цвет"
        label.font = .systemFont(ofSize: 19, weight: .bold)
        return label
    }()
    
    private lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.reuseId)
        return collectionView
    }()
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Новая привычка"
        setupLayout()
        buttonsView.createButton.addTarget(self, action: #selector(createTrackerTapped), for: .touchUpInside)
    }
    
    private func setupLayout() {
        view.addSubview(scrollView)
        view.addSubview(buttonsView)
        scrollView.addSubview(contentStackView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        
        [textFieldView, optionsTableView, emojiLabel, emojiCollectionView, colorLabel, colorCollectionView].forEach {
            contentStackView.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonsView.topAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),
            
            buttonsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonsView.heightAnchor.constraint(equalToConstant: 60),
            
            textFieldView.heightAnchor.constraint(equalToConstant: 75),
            optionsTableView.heightAnchor.constraint(equalToConstant: CGFloat(options.count * 75)),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 204),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 220),
        ])
    }
    @objc private func createTrackerTapped() {
        guard let title = textFieldView.text, !title.isEmpty else {
            showAlert(message: "Введите название трекера")
            return
        }
        
        guard let emojiIndex = selectedEmojiIndex else {
            showAlert(message: "Выберите emoji")
            return
        }
        
        guard let colorIndex = selectedColorIndex else {
            showAlert(message: "Выберите цвет")
            return
        }
        
        let tracker = Tracker(
            id: UUID(),
            name: title,
            emoji: emojis[emojiIndex.item],
            color: colors[colorIndex.item],
            schedule: []
        )
        
        delegate?.didCreateTracker(tracker)
        dismiss(animated: true)
    }
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }
    private func updateScheduleOptionText() {
        guard let cell = optionsTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TrackerOptionCell else { return }
        
        if selectedSchedule.count == 7 {
            cell.setDetailText("Каждый день")
        } else if selectedSchedule.isEmpty {
            cell.setDetailText("Не выбрано")
        } else {
            let sortedDays = selectedSchedule.sorted { $0.rawValue < $1.rawValue }
            let shortNames = sortedDays.map { $0.shortName } //
            cell.setDetailText(shortNames.joined(separator: ", "))
        }
    }
}

extension CreateTrackerViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackerOptionCell.reuseIdentifier) as? TrackerOptionCell else {
            return UITableViewCell()
        }
        let option = options[indexPath.row]
        cell.configure(with: option)
        
        if option == .schedule && !selectedSchedule.isEmpty {
            let daysText = selectedSchedule.map { $0.shortName }.joined(separator: ", ")
            cell.setDetailText(daysText)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectionOption = options[indexPath.row]
        
        switch selectionOption {
        case .schedule:
            let scheduleVC = ScheduleViewController()
            scheduleVC.delegate = self
            let nav = UINavigationController(rootViewController: scheduleVC)
            present(nav, animated: true)
            
        case .category:
            let categoryVC = CategoryViewControler()
            let nav2 = UINavigationController(rootViewController: categoryVC)
            present(nav2, animated: true)
        }
    }
}
extension CreateTrackerViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojiCollectionView {
            return emojis.count
        } else {
            return colors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.reuseId, for: indexPath) as? EmojiCell else {
                return UICollectionViewCell()
            }
            let emoji = emojis[indexPath.item]
            let isSelected = selectedEmojiIndex == indexPath
            cell.configure(with: emoji, isSelected: isSelected)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.reuseId, for: indexPath) as? ColorCell else {
                return UICollectionViewCell()
            }
            let color = colors[indexPath.item]
            let isSelected = selectedColorIndex == indexPath
            cell.configure(with: color, isSelected: isSelected)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            selectedEmojiIndex = indexPath
            collectionView.reloadData()
        } else {
            let collectionView = colorCollectionView
            selectedColorIndex = indexPath
            collectionView.reloadData()
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.bounds.width - (5 * 5)) / 6
        return CGSize(width: cellWidth, height: 52)
    }
}
