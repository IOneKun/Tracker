import UIKit

final class StatisticsCell: UICollectionViewCell {
    
    static let reuseIdentifier = "StatisticsCell"
    let color = Color()
    // MARK: - UI
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .blackDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .blackDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var innerBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = color.viewBackgroundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private let gradientBorderLayer = CAGradientLayer()
    private let borderMaskLayer = CAShapeLayer()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        contentView.layer.addSublayer(gradientBorderLayer)
        
        contentView.addSubview(innerBackgroundView)
        innerBackgroundView.addSubview(titleLabel)
        innerBackgroundView.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            innerBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 1),
            innerBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1),
            innerBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 1),
            innerBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -1),
            
            titleLabel.leadingAnchor.constraint(equalTo: innerBackgroundView.leadingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: innerBackgroundView.topAnchor, constant: 12),
            
            valueLabel.leadingAnchor.constraint(equalTo: innerBackgroundView.leadingAnchor, constant: 12),
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let cornerRadius: CGFloat = 16
        let borderWidth: CGFloat = 1
        
        gradientBorderLayer.frame = contentView.bounds
        gradientBorderLayer.cornerRadius = cornerRadius
        gradientBorderLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientBorderLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        let path = UIBezierPath(roundedRect: contentView.bounds.insetBy(dx: borderWidth / 2, dy: borderWidth / 2), cornerRadius: cornerRadius)
        let maskPath = UIBezierPath(roundedRect: contentView.bounds.insetBy(dx: borderWidth + 0.5, dy: borderWidth + 0.5), cornerRadius: cornerRadius)
        path.append(maskPath.reversing())
        
        borderMaskLayer.path = path.cgPath
        gradientBorderLayer.mask = borderMaskLayer
    }
    
    // MARK: - Public
    
    func configure(value: Int, title: String, gradientColors: [UIColor]) {
        valueLabel.text = "\(value)"
        titleLabel.text = title
        gradientBorderLayer.colors = gradientColors.map { $0.cgColor }
    }
}


