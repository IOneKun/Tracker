import Foundation
import UIKit

final class TrackerTextFieldView: UIView {
    //MARK: - UI Elements
    let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.backgroundColor = .grayDay
        textField.layer.cornerRadius = 16
        
        let paddingView = UIView(frame: CGRect(x: 0, y:0, width: 16, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        return textField
    }()
    var text: String? {
        return textField.text
    }
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - Function 
    private func setupLayout() {
        addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
