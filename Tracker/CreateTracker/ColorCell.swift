import UIKit

final class ColorCell: UICollectionViewCell {
    static let reuseId = "ColorCell"
    
    private let selectedBorderLayer = CALayer()
    
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(colorView)
        
        colorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40)
        ])
        selectedBorderLayer.cornerRadius = 16
        selectedBorderLayer.borderWidth = 3
        selectedBorderLayer.isHidden = true
        contentView.layer.addSublayer(selectedBorderLayer)
    }
    override func layoutSubviews() {
            super.layoutSubviews()
            let size: CGFloat = 52
            selectedBorderLayer.frame = CGRect(
                x: (contentView.bounds.width - size) / 2,
                y: (contentView.bounds.height - size) / 2,
                width: size,
                height: size
            )
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func configure(with color: UIColor, isSelected: Bool) {
        colorView.backgroundColor = color
        
        selectedBorderLayer.isHidden = !isSelected
        
        if isSelected {
            selectedBorderLayer.borderColor = color.withAlphaComponent(0.3).cgColor
        }
    }
}
