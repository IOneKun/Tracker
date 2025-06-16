   /* import Foundation

    import UIKit

    final class ColorSectionView: UIView {
        // MARK: - Public
        var onColorSelected: ((UIColor) -> Void)?
        
        var selectedColor: UIColor? {
            didSet {
                collectionView.reloadData()
            }
        }
        
        // MARK: - Private
        
        private let colors: [UIColor] = [.color1, .color2, .color3, .color4, .color5, .color6, .color7, .color8, .color9, .color10, .color11, .color12, .color13, .color14, .color15, .color16, .color17, .color18]
        private let titleLabel: UILabel = {
            let label = UILabel()
            label.text = "Цвет"
            label.font = .systemFont(ofSize: 19, weight: .bold)
            return label
        }()
        
        private lazy var collectionView: UICollectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: 52, height: 52)
            layout.minimumInteritemSpacing = 5
            layout.minimumLineSpacing = 10
            
            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.reuseId)
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.isScrollEnabled = false  
            return collectionView
        }()
        
        // MARK: - Init
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupViews()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - Layout
        private func setupViews() {
            addSubview(titleLabel)
            addSubview(collectionView)
            
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: topAnchor),
                titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
                titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
                
                collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
                collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
                collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
                collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
                collectionView.heightAnchor.constraint(equalToConstant: 204)
            ])
        }
    }

    // MARK: - UICollectionViewDataSource, UICollectionViewDelegate
    extension ColorSectionView: UICollectionViewDataSource, UICollectionViewDelegate {
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return colors.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.reuseId, for: indexPath) as? ColorCell else {
                return UICollectionViewCell()
            }
            let color = colors[indexPath.item]
            let isSelected = (color == selectedColor)
            cell.configure(with: color, isSelected: isSelected)
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            selectedColor = colors[indexPath.item]
            onColorSelected?(selectedColor!)
        }
    }*/
