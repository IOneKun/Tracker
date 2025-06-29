import UIKit

final class ScheduleSwitchCell: UITableViewCell {
    //MARK: - UI Elements
    static let identifier = "ScheduleSwitchCell"
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17)
        label.textColor = .blackDay
        return label
    }()
    
    private let toggleSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.onTintColor = .blueDay
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()
    
    var switchChanged: ((Bool) -> Void)?
    
    //MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .grayDay
        selectionStyle = .none
        contentView.addSubview(titleLabel)
        contentView.addSubview(toggleSwitch)
        
        toggleSwitch.addTarget(self, action: #selector(switchToggled), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            toggleSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            toggleSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Functions
    func configure(with day: Weekday, isEnabled: Bool) {
        titleLabel.text = day.displayName
        toggleSwitch.isOn = isEnabled
    }
    
    @objc private func switchToggled() {
        switchChanged?(toggleSwitch.isOn)
    }
}

