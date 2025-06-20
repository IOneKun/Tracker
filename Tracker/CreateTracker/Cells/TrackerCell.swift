import UIKit

protocol TrackerCellDelegate: AnyObject {
    func trackerCellDidTapComplete(_ cell: TrackerCell)
}
final class TrackerCell: UICollectionViewCell {
    
    weak var delegate: TrackerCellDelegate?
    static let identifier = "TrackerCell"
    
    // MARK: - UI Elements
    
    private let coloredBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bottomPanel: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let daysLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "plus_button"), for: .normal)
        button.layer.cornerRadius = 17
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        setupLayout()
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Configure
    
    @objc private func plusButtonTapped() {
        delegate?.trackerCellDidTapComplete(self)
    }
    
    func configure(with tracker: Tracker, completedDays: Int, isCompleted: Bool) {
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.name
        if completedDays % 100 >= 11 && completedDays % 100 <= 14 {
            daysLabel.text = "\(completedDays) дней"
        } else {
            switch completedDays % 10 {
            case 1:
                daysLabel.text = "\(completedDays) день"
            case 2, 3, 4:
                daysLabel.text = "\(completedDays) дня"
            default:
                daysLabel.text = "\(completedDays) дней"
            }
        }
        coloredBackgroundView.backgroundColor = tracker.color
        
        let buttonImageName = isCompleted ? "done_button" : "plus_button"
        plusButton.setImage(UIImage(named: buttonImageName), for: .normal)
        plusButton.tintColor = tracker.color
    }
    
    // MARK: - Layout
    
    private func setupLayout() {
        contentView.addSubview(coloredBackgroundView)
        coloredBackgroundView.addSubview(emojiLabel)
        coloredBackgroundView.addSubview(titleLabel)
        
        contentView.addSubview(bottomPanel)
        bottomPanel.addSubview(daysLabel)
        bottomPanel.addSubview(plusButton)
        
        NSLayoutConstraint.activate([
            coloredBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
            coloredBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            coloredBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            coloredBackgroundView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.topAnchor.constraint(equalTo: coloredBackgroundView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: coloredBackgroundView.leadingAnchor, constant: 12),
            
            titleLabel.leadingAnchor.constraint(equalTo: coloredBackgroundView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: coloredBackgroundView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: coloredBackgroundView.bottomAnchor, constant: -12),
            
            bottomPanel.topAnchor.constraint(equalTo: coloredBackgroundView.bottomAnchor),
            bottomPanel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomPanel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomPanel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            daysLabel.leadingAnchor.constraint(equalTo: bottomPanel.leadingAnchor, constant: 12),
            daysLabel.centerYAnchor.constraint(equalTo: bottomPanel.centerYAnchor),
            
            plusButton.trailingAnchor.constraint(equalTo: bottomPanel.trailingAnchor, constant: -12),
            plusButton.centerYAnchor.constraint(equalTo: bottomPanel.centerYAnchor),
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
}

