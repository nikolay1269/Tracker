//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Nikolay on 17.12.2024.
//

import UIKit

enum WeekDay: Int {
    case monday = 0
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
}

class ScheduleViewController: UIViewController {
    
    private let tableView = UITableView()
    private let titleLabel = UILabel()
    private let doneButton = UIButton()
    private let scheduleCellIdentifier = "scheduleCellIdentifier"
    private let dayOfWeekNames = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
    var dayOfWeekSelected: Set<WeekDay> = Set<WeekDay>()
    var scheduleSelected: ((Set<WeekDay>) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addTitle()
        addScheduleTableView()
        addDoneButton()
    }
    
    private func addTitle() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 35).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.text = "Расписание"
        titleLabel.font = UIFont(name: "SF Pro Medium", size: 16)
        titleLabel.textColor = UIColor(named: "YPBlack")
        titleLabel.textAlignment = .center
    }
    
    private func addScheduleTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.register(ScheduleTableViewCell.self, forCellReuseIdentifier: scheduleCellIdentifier)
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24).isActive = true
        tableView.heightAnchor.constraint(equalToConstant: 525).isActive = true
        tableView.dataSource = self
        tableView.rowHeight = 75
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor(named: "YPGray")
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.reloadData()
    }
    
    private func addDoneButton() {
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(doneButton)
        let font = UIFont(name: "SF Pro Medium", size: 16) ?? UIFont.systemFont(ofSize: 17)
        let color = UIColor(named: "YPWhite") ?? .white
        let attributes = [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor : color]
        let attributedTitle = NSAttributedString(string: "Готово", attributes: attributes)
        doneButton.setAttributedTitle(attributedTitle, for: .normal)
        doneButton.layer.cornerRadius = 16
        doneButton.backgroundColor = UIColor(named: "YPBlack")
        doneButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
    }
    
    @objc private func doneButtonTapped() {
        guard let scheduleSelected = scheduleSelected else { return }
        scheduleSelected(dayOfWeekSelected)
        self.dismiss(animated: true)
    }
}

extension ScheduleViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dayOfWeekNames.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: scheduleCellIdentifier) as? ScheduleTableViewCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        cell.textLabel?.font = UIFont(name: "SF Pro Regular", size: 17)
        cell.textLabel?.textColor = UIColor(named: "YPBlack")
        cell.textLabel?.text = dayOfWeekNames[indexPath.row]
        cell.dayOfWeekValueChanged = { [weak self] isOn in
            guard let dayOfWeek = WeekDay(rawValue: indexPath.row) else { return }
            if isOn {
                self?.dayOfWeekSelected.insert(dayOfWeek)
            } else {
                self?.dayOfWeekSelected.remove(dayOfWeek)
            }
        }
        return cell
    }
}