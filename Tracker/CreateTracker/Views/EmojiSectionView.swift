    import Foundation
    import UIKit

    final class EmojiSectionView: UIView {
        // MARK: - Public
        var onEmojiSelected: ((String) -> Void)?

        var selectedEmoji: String? {
            didSet {
                collectionView.reloadData()
            }
        }

        // MARK: - Private
        private let emojis = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
        
        private let titleLabel: UILabel = {
            let label = UILabel()
            label.text = "Emoji"
            label.font = .systemFont(ofSize: 19, weight: .bold)
            return label
        }()

        private lazy var collectionView: UICollectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: 52, height: 52)
            layout.minimumInteritemSpacing = 5
            layout.minimumLineSpacing = 10

            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.reuseId)
            collectionView.isScrollEnabled = false
            collectionView.delegate = self
            collectionView.dataSource = self
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
                collectionView.heightAnchor.constraint(equalToConstant: 120)
            ])
        }
    }

    extension EmojiSectionView: UICollectionViewDataSource, UICollectionViewDelegate {
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return emojis.count
        }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.reuseId, for: indexPath) as? EmojiCell else {
                return UICollectionViewCell()
            }
            let emoji = emojis[indexPath.item]
            let isSelected = (emoji == selectedEmoji)
            cell.configure(with: emoji, isSelected: isSelected)
            return cell
        }

        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            selectedEmoji = emojis[indexPath.item]
            onEmojiSelected?(selectedEmoji!)
        }
    }
