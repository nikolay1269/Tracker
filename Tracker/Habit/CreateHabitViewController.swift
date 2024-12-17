//
//  NewHabitViewController.swift
//  Tracker
//
//  Created by Nikolay on 16.12.2024.
//

import UIKit

enum HabitParams: Int {
    case category
    case schedule
}

class CreateHabitViewController: UIViewController {
    
    let titleLabel = UILabel()
    let nameTextField = UITextField()
    let createButton = UIButton()
    let cancelButton = UIButton()
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addTitleLabel()
        addNameTextField()
        addCreateButton()
        addCancelButton()
        addParamsTalbeView()
    }
    
    private func addTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 35).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.text = "Новая привычка"
        titleLabel.font = UIFont(name: "SF Pro Medium", size: 16)
        titleLabel.textAlignment = .center
    }
    
    private func addNameTextField() {
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameTextField)
        nameTextField.placeholder = "Введите название трекера"
        nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24).isActive = true
        nameTextField.font = UIFont(name: "SF Pro Regular", size: 17)
        nameTextField.backgroundColor = UIColor(named: "TextFieldBackgroundColor")
        nameTextField.heightAnchor.constraint(equalToConstant: 75).isActive = true
        nameTextField.layer.cornerRadius = 16
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 75))
        paddingView.backgroundColor = UIColor(named: "TextFieldBackgroundColor")
        nameTextField.leftView = paddingView
        nameTextField.leftViewMode = .always
    }
    
    private func addCreateButton() {
        createButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(createButton)
        let font = UIFont(name: "SF Pro Medium", size: 16) ?? UIFont.systemFont(ofSize: 17)
        let color = UIColor(named: "YPWhite") ?? UIColor.black
        let attributes = [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor : color]
        let attributedTitle = NSAttributedString(string: "Создать", attributes: attributes)
        createButton.setAttributedTitle(attributedTitle, for: .normal)
        createButton.layer.cornerRadius = 16
        createButton.backgroundColor = UIColor(named: "YPGray")
        createButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        createButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34).isActive = true
        createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        //createButton.widthAnchor.constraint(equalToConstant: 161).isActive = true
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
    }
    
    @objc private func createButtonTapped() {
        
    }
    
    private func addCancelButton() {
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cancelButton)
        let font = UIFont(name: "SF Pro Medium", size: 16) ?? UIFont.systemFont(ofSize: 17)
        let color = UIColor(named: "YPRed") ?? UIColor.black
        let attributes = [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor : color]
        let attributedTitle = NSAttributedString(string: "Создать", attributes: attributes)
        cancelButton.setAttributedTitle(attributedTitle, for: .normal)
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.borderColor = UIColor(named: "YPRed")?.cgColor
        cancelButton.layer.borderWidth = 1
        cancelButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        cancelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34).isActive = true
        cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        cancelButton.trailingAnchor.constraint(equalTo: createButton.leadingAnchor, constant: -12).isActive = true
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cancelButton.widthAnchor.constraint(equalTo: createButton.widthAnchor).isActive = true
    }
    
    @objc private func cancelButtonTapped() {
        
    }
    
    private func addParamsTalbeView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24).isActive = true
        tableView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 75
        tableView.layer.cornerRadius = 16
        tableView.reloadData()
    }
}

extension CreateHabitViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor(named: "TextFieldBackgroundColor")
        cell.accessoryType = .disclosureIndicator
        switch (indexPath.row) {
        case HabitParams.category.rawValue:
            cell.textLabel?.text = "Категория"
        case HabitParams.schedule.rawValue:
            cell.textLabel?.text = "Расписание"
        default:
            break
        }
        return cell
    }
}

extension CreateHabitViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch(indexPath.row) {
        case HabitParams.category.rawValue:
            print("Select default category")
        case HabitParams.schedule.rawValue:
            print("Open schedule screen")
        default:
            break
        }
    }
}
