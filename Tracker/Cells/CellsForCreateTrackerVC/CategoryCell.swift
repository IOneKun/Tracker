import UIKit

final class CategoryCell: UITableViewCell {
    static let reuseIdentifier = "CategoryCell"
    
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
    // MARK: - Functions
    
    private func configureUI() {
        backgroundColor = .grayDay
        selectionStyle = .none
        
        nameLabel.font = UIFont.systemFont(ofSize: 17)
        nameLabel.textColor = .label
        
        checkmarkImageView.image = UIImage(systemName: "checkmark")
        checkmarkImageView.tintColor = .blueDay 
        checkmarkImageView.isHidden = true
        checkmarkImageView.setContentHuggingPriority(.required, for: .horizontal)
        
        let mainStack = UIStackView(arrangedSubviews: [nameLabel, checkmarkImageView])
        mainStack.axis = .horizontal
        mainStack.alignment = .center
        mainStack.spacing = 8
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with category: String, isSelected: Bool) {
        nameLabel.text = category
        checkmarkImageView.isHidden = !isSelected
    }
}

