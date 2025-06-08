import Foundation
import UIKit

class CreateTrackerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate {
    
    enum TrackerOption: String, CaseIterable {
        case category = "Категория"
        case schedule = "Расписание"
    }
    private let scrollView = UIScrollView()
    private let contentView = UIStackView()
    
    private let emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    private let colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    let emojiArray = ["🙂","😻","🌺","🐶","❤️", "😱","😇","😡", "🥶","🤔", "🙌","🍔","🥦","🏓","🥇","🎸","🏝","😪"]
    let colorArray: [UIColor] = [.color1, .color2, .color3, .color4, .color5, .color6, .color7, .color8, .color9, .color10, .color11, .color12, .color13, .color14, .color15, .color16, .color17, .color18]
    
    let tableView = UITableView()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        title = "Новая привычка"
        setupUI()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojiCollectionView {
            return emojiArray.count
        } else if collectionView == colorCollectionView {
            return colorArray.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath)
            let label = UILabel()
            label.text = emojiArray[indexPath.item]
            label.font = UIFont.systemFont(ofSize: 32)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            
            cell.contentView.subviews.forEach { $0.removeFromSuperview()}
            cell.contentView.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
            ])
            cell.backgroundColor = .white
            cell.layer.cornerRadius = 16
            
            return cell
        } else if collectionView == colorCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorSet", for: indexPath)
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }
            
            cell.backgroundColor = colorArray[indexPath.item]
            cell.layer.cornerRadius = 16
            return cell
        }
        return UICollectionViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TrackerOption.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let option = TrackerOption.allCases[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath)
        
        cell.textLabel?.text = option.rawValue
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .default
        cell.backgroundColor = .grayDay
        if indexPath.row == TrackerOption.allCases.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = TrackerOption.allCases[indexPath.row]
        switch option {
        case .category:
            print("Выбрана категория")
        case .schedule:
            print("Выбран график")
        }
    }
    
        func setupUI() {
            view.addSubview(scrollView)
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: view.topAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
            scrollView.addSubview(contentView)
            contentView.axis = .vertical
            contentView.spacing = 24
            contentView.isLayoutMarginsRelativeArrangement = true
            contentView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 24, right: 16)
            contentView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
                contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
            ])
            
            let trackerNameTextField: UITextField = {
                let textField = UITextField()
                textField.placeholder = "Введите название трекера"
                textField.backgroundColor = .grayDay
                textField.layer.cornerRadius = 16
                textField.translatesAutoresizingMaskIntoConstraints = false
                
                let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 75))
                textField.leftView = paddingView
                textField.leftViewMode = .always
                
                return textField
            }()
            
            contentView.addArrangedSubview(trackerNameTextField)
            NSLayoutConstraint.activate([
                trackerNameTextField.heightAnchor.constraint(equalToConstant: 75)
            ])
            
            tableView.isScrollEnabled = false
            tableView.layer.cornerRadius = 16
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "OptionCell")
            tableView.delegate = self
            tableView.dataSource = self
            contentView.addArrangedSubview(tableView)
            
            tableView.translatesAutoresizingMaskIntoConstraints = false
            tableView.separatorStyle = .singleLine
            tableView.separatorColor = .black
            
            NSLayoutConstraint.activate([
                tableView.heightAnchor.constraint(equalToConstant: 180)
            ])
            
            let emojiLabel = UILabel()
            emojiLabel.text = "Emoji"
            emojiLabel.font = UIFont.systemFont(ofSize: 19, weight: .bold)
            emojiLabel.textColor = .blackDay
            emojiLabel.translatesAutoresizingMaskIntoConstraints = false
            
            contentView.addArrangedSubview(emojiLabel)
            
            view.backgroundColor = .white
            emojiCollectionView.backgroundColor = .clear
            emojiCollectionView.delegate = self
            emojiCollectionView.dataSource = self
            emojiCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "EmojiCell")
            
            contentView.addArrangedSubview(emojiCollectionView)
            
            NSLayoutConstraint.activate([
                emojiCollectionView.heightAnchor.constraint(equalToConstant: 190)
            ])
            
            let colorLabel = UILabel()
            colorLabel.text = "Цвет"
            colorLabel.font = UIFont.systemFont(ofSize: 19, weight: .bold)
            colorLabel.textColor = .blackDay
            
            colorLabel.translatesAutoresizingMaskIntoConstraints = false
            contentView.addArrangedSubview(colorLabel)
            
            colorCollectionView.delegate = self
            colorCollectionView.dataSource = self
            colorCollectionView.backgroundColor = .clear
            colorCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "ColorSet")
            
            colorCollectionView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addArrangedSubview(colorCollectionView)
            
            NSLayoutConstraint.activate([
                colorCollectionView.heightAnchor.constraint(equalToConstant: 190)
            ])
        }
    }

    extension CreateTrackerViewController: UICollectionViewDelegateFlowLayout {
        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            sizeForItemAt indexPath: IndexPath) -> CGSize {
            let width = (collectionView.frame.width - 32) / 6
            return CGSize(width: width, height: width)
        }
    }
