//
//  NewHabitViewController.swift
//  Tracker
//
//  Created by Nikolay on 16.12.2024.
//

import UIKit

enum TrackerParams: Int {
    case category
    case schedule
}

enum TrackerType: Int {
    case habit
    case event
}

class CreateTrackerViewController: UIViewController {
    
    private let titleLabel = UILabel()
    private let nameTextField = UITextField()
    private let createButton = UIButton()
    private let cancelButton = UIButton()
    private let tableView = UITableView()
    private let maxLengthLabel = UILabel()
    private var nameStackView = UIStackView()
    private var maxLabelHeightConstraint: NSLayoutConstraint?
    
    private let nameMaxLength = 38
    var dayOfWeekSelected: Set<WeekDay> = Set<WeekDay>()
    var trackerCreated: ((Tracker) -> Void)?
    var trackerType: TrackerType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addTitleLabel()
        addNameTextField()
        addMaxLengthLabel()
        addNameStackView()
        addCreateButton()
        addCancelButton()
        addParamsTalbeView()
    }
    
    private func addTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 35).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        switch(trackerType) {
        case .habit:
            titleLabel.text = "Новая привычка"
        case .event:
            titleLabel.text = "Новое нерегулярное событие"
        case .none:
            break
        }
        titleLabel.font = UIFont(name: "SF Pro Medium", size: 16)
        titleLabel.textColor = UIColor(named: "YPBlack")
        titleLabel.textAlignment = .center
    }
    
    private func addMaxLengthLabel() {
        maxLengthLabel.translatesAutoresizingMaskIntoConstraints = false
        maxLabelHeightConstraint =  maxLengthLabel.heightAnchor.constraint(equalToConstant: 0)
        maxLabelHeightConstraint?.isActive = true
        maxLengthLabel.text = "Ограничение 38 символов"
        maxLengthLabel.textAlignment = .center
        maxLengthLabel.textColor = UIColor(named: "YPRed")
        maxLengthLabel.font = UIFont(name: "SF Pro Regular", size: 17)
    }
    
    private func addNameStackView() {
        nameStackView = UIStackView(arrangedSubviews: [nameTextField, maxLengthLabel])
        nameStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameStackView)
        nameStackView.spacing = 8
        nameStackView.distribution = .fillProportionally
        nameStackView.axis = .vertical
        nameStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24).isActive = true
        nameStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        nameStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        nameStackView.isUserInteractionEnabled = true
    }
    
    private func addNameTextField() {
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        nameStackView.addSubview(nameTextField)
        nameTextField.placeholder = "Введите название трекера"
        nameTextField.font = UIFont(name: "SF Pro Regular", size: 17)
        nameTextField.backgroundColor = UIColor(named: "TextFieldBackgroundColor")
        nameTextField.heightAnchor.constraint(equalToConstant: 75).isActive = true
        nameTextField.layer.cornerRadius = 16
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 75))
        paddingView.backgroundColor = .clear
        nameTextField.leftView = paddingView
        nameTextField.leftViewMode = .always
        nameTextField.clearButtonMode = .whileEditing
        nameTextField.addTarget(self, action: #selector(nameTextFieldEditingChanged), for: .editingChanged)
    }
    
    @objc private func nameTextFieldEditingChanged() {
        checkMaxLenght()
        setCreateButtonEnabled()
    }
    
    private func checkMaxLenght() {
        if let textLength = nameTextField.text?.count, textLength > nameMaxLength {
            maxLabelHeightConstraint?.constant = 30
        } else {
            maxLabelHeightConstraint?.constant = 0
        }
    }
    
    private func setCreateButtonEnabled() {
        if allRequiredFieldsNotEmpty() == true {
            createButton.backgroundColor = UIColor(named: "YPBlack")
            createButton.isEnabled = true
        } else {
            createButton.backgroundColor = UIColor(named: "YPGray")
            createButton.isEnabled = false
        }
    }
    
    private func allRequiredFieldsNotEmpty() -> Bool {
        guard let count = nameTextField.text?.count, count > 0 && count <= nameMaxLength && (dayOfWeekSelected.count > 0 || trackerType == .event) else { return false }
        return true
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
        createButton.isEnabled = false
        createButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        createButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34).isActive = true
        createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
    }
    
    @objc private func createButtonTapped() {
        guard let trackerCreated = trackerCreated else { return }
        self.dismiss(animated: true)
        trackerCreated(createTracker())
    }
    
    private func createTracker() -> Tracker {
        Tracker(id: UUID(), name: nameTextField.text ?? "", color: UIColor(named: "TCGreen") ?? .green, emoji: "🙂", schedule: dayOfWeekSelected)
    }
    
    private func addCancelButton() {
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cancelButton)
        let font = UIFont(name: "SF Pro Medium", size: 16) ?? UIFont.systemFont(ofSize: 17)
        let color = UIColor(named: "YPRed") ?? UIColor.black
        let attributes = [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor : color]
        let attributedTitle = NSAttributedString(string: "Отменить", attributes: attributes)
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
        dismiss(animated: true)
    }
    
    private func addParamsTalbeView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        tableView.topAnchor.constraint(equalTo: nameStackView.bottomAnchor, constant: 24).isActive = true
        var tableHeight: CGFloat = 0
        switch (trackerType) {
        case .habit:
            tableHeight = 150
        case .event:
            tableHeight = 75
        case .none:
            tableHeight = 0
        }
        tableView.heightAnchor.constraint(equalToConstant: tableHeight).isActive = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 75
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor(named: "YPGray")
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.reloadData()
    }
}

extension CreateTrackerViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch(trackerType) {
        case .habit:
            return 2
        case .event:
            return 1
        case .none:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.selectionStyle = .none
        cell.textLabel?.font = UIFont(name: "SF Pro Regular", size: 17)
        cell.textLabel?.textColor = UIColor(named: "YPBlack")
        cell.detailTextLabel?.font = UIFont(name: "SF Pro Regular", size: 17)
        cell.detailTextLabel?.textColor = UIColor(named: "YPGray")
        cell.backgroundColor = UIColor(named: "TextFieldBackgroundColor")
        cell.accessoryType = .disclosureIndicator
        let lastIndex = trackerType == .habit ? 1 : 0
        if indexPath.row == lastIndex {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.size.width)
        }
        switch (indexPath.row) {
        case TrackerParams.category.rawValue:
            cell.textLabel?.text = "Категория"
            cell.detailTextLabel?.text = "Важное"
        case TrackerParams.schedule.rawValue:
            cell.textLabel?.text = "Расписание"
        default:
            break
        }
        return cell
    }
}

extension CreateTrackerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch(indexPath.row) {
        case TrackerParams.category.rawValue:
            print("Select default category")
        case TrackerParams.schedule.rawValue:
            let scheduleViewController = ScheduleViewController()
            scheduleViewController.scheduleSelected = { [weak self] dayOfWeekSelected in
                guard let self = self else { return }
                var scheduleInfo: String = ""
                for dayOfWeek in dayOfWeekSelected.sorted(by: { weekday1, weekday2 in
                    (weekday1.rawValue < weekday2.rawValue || weekday2 == .sunday) && !(weekday1 == .sunday)
                }) {
                    var shortDayOfWeek = ""
                    switch(dayOfWeek) {
                    case .monday:
                        shortDayOfWeek = "Пн"
                    case .tuesday:
                        shortDayOfWeek = "Вт"
                    case .wednesday:
                        shortDayOfWeek = "Ср"
                    case .thursday:
                        shortDayOfWeek = "Чт"
                    case .friday:
                        shortDayOfWeek = "Пт"
                    case .saturday:
                        shortDayOfWeek = "Сб"
                    case .sunday:
                        shortDayOfWeek = "Вс"
                    }
                    scheduleInfo.append("\(shortDayOfWeek), ")
                }
                if scheduleInfo.count > 1 {
                    scheduleInfo.removeLast(2)
                }
                self.dayOfWeekSelected = dayOfWeekSelected
                guard let cell = tableView.cellForRow(at: IndexPath(row: TrackerParams.schedule.rawValue, section: 0)) else { return }
                cell.detailTextLabel?.text = scheduleInfo
                self.setCreateButtonEnabled()
            }
            self.present(scheduleViewController, animated: true)
        default:
            break
        }
    }
}
