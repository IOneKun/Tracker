import Foundation
import UIKit

final class TrackerOptionCell: UITableViewCell {
    //MARK: - UI ELements
    static let reuseIdentifier = "TrackerOptionCell"
    
    private let optionNameLabel = UILabel()
    private let selectedValueLabel = UILabel()
    private let chevronImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
    //MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - Functions 
    private func configureUI() {
        backgroundColor = .lightGrayDay
        
        optionNameLabel.font = UIFont.systemFont(ofSize: 17)
        selectedValueLabel.font = UIFont.systemFont(ofSize: 15)
        selectedValueLabel.textColor = .blackDay
        selectedValueLabel.numberOfLines = 1
        
        chevronImageView.tintColor = .grayDay2
        chevronImageView.setContentHuggingPriority(.required, for: .horizontal)
        
        let labelsStack = UIStackView(arrangedSubviews: [optionNameLabel, selectedValueLabel])
        labelsStack.axis = .vertical
        labelsStack.spacing = 2
        
        let mainStack = UIStackView(arrangedSubviews: [labelsStack, chevronImageView])
        mainStack.axis = .horizontal
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with type: TrackerOptionType) {
        optionNameLabel.text = type.title
    }
    
    func setDetailText(_ text: String) {
        selectedValueLabel.text = text
    }
}

