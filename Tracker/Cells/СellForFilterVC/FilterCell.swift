import UIKit

final class FilterCell: UITableViewCell {
    static let reuseIdentifier = "FilterCell"

    // MARK: - UI Elements
    private let nameLabel = UILabel()
    private let checkmarkImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func configureUI() {
        backgroundColor = .grayDay
        selectionStyle = .none

        nameLabel.font = UIFont.systemFont(ofSize: 17)
        nameLabel.textColor = .label

        checkmarkImageView.image = UIImage(systemName: "checkmark")
        checkmarkImageView.tintColor = .blue
        checkmarkImageView.isHidden = true
        checkmarkImageView.setContentHuggingPriority(.required, for: .horizontal)

        let stackView = UIStackView(arrangedSubviews: [nameLabel, checkmarkImageView])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    // MARK: - Public
    func configure(with filterName: String, isSelected: Bool) {
        nameLabel.text = filterName
        checkmarkImageView.isHidden = !isSelected
    }
}


