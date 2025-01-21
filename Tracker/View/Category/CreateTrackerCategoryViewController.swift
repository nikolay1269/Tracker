//
//  CreateTrackerCategoryViewController.swift
//  Tracker
//
//  Created by Nikolay on 20.01.2025.
//

import UIKit

class CreateTrackerCategoryViewController: UIViewController {
    
    var viewModel: TrackerCategoriesViewModel?

    // MARK: - IB Outlets
    private lazy var newTrackerCategoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Новая категория"
        label.font = UIFont(name: "SF Pro Regular", size: 16)
        return label
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: "YPBlack")
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        let font = UIFont(name: "SF Pro Medium", size: 16) ?? UIFont.systemFont(ofSize: 16)
        let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : font,
                                                          NSAttributedString.Key.foregroundColor : UIColor.white]
        let attributedTitle = NSAttributedString(string: "Готово", attributes: attributes)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var trackerCategoryNameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        let attributes = [NSAttributedString.Key.foregroundColor : UIColor(named: "YPGray") ?? .gray]
        let attributePlacedHolder = NSAttributedString(string: "Введите название категории", attributes: attributes)
        textField.attributedPlaceholder = attributePlacedHolder
        textField.backgroundColor = UIColor(named: "TextFieldBackgroundColor")
        textField.textColor = UIColor(named: "YPBlack")
        textField.font = UIFont(name: "SF Pro Regular", size: 17)
        textField.layer.cornerRadius = 16
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 75))
        paddingView.backgroundColor = .clear
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.clearButtonMode = .whileEditing
        textField.addTarget(self, action: #selector(trackerCategoryNameTextFieldEditingChanged), for: .editingChanged)
        return textField
    }()
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    // MARK: - IB Actions
    @objc private func doneButtonTapped() {
        viewModel?.addTrackerCategoryTapped(name: trackerCategoryNameTextField.text ?? "")
        dismiss(animated: true)
    }
    
    @objc private func trackerCategoryNameTextFieldEditingChanged() {
        let enable = !(trackerCategoryNameTextField.text?.isEmpty ?? true)
        changeDoneButtonEnable(enable)
    }
    
    // MARK: - Private Methods
    private func changeDoneButtonEnable(_ enable: Bool) {
        doneButton.isEnabled = enable
        switch(enable) {
        case true:
            doneButton.backgroundColor = UIColor(named: "YPBlack")
        case false:
            doneButton.backgroundColor = UIColor(named: "YPGray")
        }
    }
    
    private func setupLayout() {
        
        view.backgroundColor = .white
        changeDoneButtonEnable(false)
        view.addSubview(doneButton)
        view.addSubview(newTrackerCategoryLabel)
        view.addSubview(trackerCategoryNameTextField)
        
        NSLayoutConstraint.activate([
            trackerCategoryNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerCategoryNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackerCategoryNameTextField.topAnchor.constraint(equalTo: newTrackerCategoryLabel.bottomAnchor, constant: 14),
            trackerCategoryNameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            newTrackerCategoryLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 28),
            newTrackerCategoryLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
