import Foundation
import UIKit

protocol CreateCategoryViewControllerDelegate: AnyObject {
    func didCreateCategory(_ category: String)
}

final class CreateCategoryViewController: UIViewController {
    
    weak var delegate: CreateCategoryViewControllerDelegate?
    
    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.isEnabled = false 
        button.backgroundColor = .gray
        button.layer.cornerRadius = 16
        return button
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Введите название категории"
        textField.backgroundColor = .systemGray6
        textField.layer.cornerRadius = 10
        textField.font = .systemFont(ofSize: 17)
        textField.setLeftPaddingPoints(12)
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Новая категория"
        view.backgroundColor = .white
        doneButton.addTarget(self, action: #selector(doneCategoryButtonTapped), for: .touchUpInside)
        setupLayout()
        textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        updateDoneButtonState()
    }
    
    func setupLayout() {
        view.addSubview(textField)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    @objc private func doneCategoryButtonTapped() {
        guard let categoryName = textField.text, !categoryName.isEmpty else {
            return
        }
        delegate?.didCreateCategory(categoryName)
        dismiss(animated: true)
    }
    @objc private func textFieldChanged() {
        updateDoneButtonState()
    }
    private func updateDoneButtonState() {
        let hasText = !(textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        doneButton.isEnabled = hasText
        doneButton.backgroundColor = hasText ? .blackDay : .gray
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}
