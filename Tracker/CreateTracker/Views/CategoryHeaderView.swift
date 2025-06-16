import Foundation
import UIKit

final class CategoryHeaderView: UICollectionReusableView {
    static let identifier = "CategoryHeaderView"
    
    private let titleCategory: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = .blackDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleCategory)
        NSLayoutConstraint.activate([
            titleCategory.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleCategory.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleCategory.topAnchor.constraint(equalTo: topAnchor),
            titleCategory.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func configure(with title: String) {
        titleCategory.text = title
    }
}
