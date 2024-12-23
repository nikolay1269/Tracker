//
//  CreateTrackerViewController.swift
//  Tracker
//
//  Created by Nikolay on 15.12.2024.
//

import UIKit

class SelectTrackerTypeViewController: UIViewController {
    
    private let titleLabel = UILabel()
    private let habitButton = UIButton()
    private let eventButton = UIButton()
    private var newTracker: Tracker?
    var trackerCreated: ((Tracker) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addTitleLabel()
        addHabitButton()
        addEventButton()
    }
    
    private func addTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 35).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.text = "Создание трекера"
        titleLabel.font = UIFont(name: "SF Pro Medium", size: 16)
        titleLabel.textAlignment = .center 
    }
    
    private func addHabitButton() {
        habitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(habitButton)
        habitButton.tag = TrackerType.habit.rawValue
        habitButton.backgroundColor = UIColor(named: "YPBlack")
        let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "SF Pro Medium", size: 16) ?? UIFont.systemFont(ofSize: 16),
                                                          NSAttributedString.Key.foregroundColor : UIColor.white]
        let attributedTitle = NSAttributedString(string: "Привычка", attributes: attributes)
        habitButton.setAttributedTitle(attributedTitle, for: .normal)
        habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        habitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -38).isActive = true
        habitButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        habitButton.layer.cornerRadius = 16
        habitButton.addTarget(self, action: #selector(trackerTypeButtonTapped(sender:)), for: .touchUpInside)
    }
    
    private func addEventButton() {
        eventButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(eventButton)
        eventButton.tag = TrackerType.event.rawValue
        eventButton.backgroundColor = UIColor(named: "YPBlack")
        let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "SF Pro Medium", size: 16) ?? UIFont.systemFont(ofSize: 16),
                                                          NSAttributedString.Key.foregroundColor : UIColor.white]
        let attributedTitle = NSAttributedString(string: "Нерегулярное событие", attributes: attributes)
        eventButton.setAttributedTitle(attributedTitle, for: .normal)
        eventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        eventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        eventButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 38).isActive = true
        eventButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        eventButton.layer.cornerRadius = 16
        eventButton.addTarget(self, action: #selector(trackerTypeButtonTapped(sender:)), for: .touchUpInside)
    }
    
    @objc private func trackerTypeButtonTapped(sender: UIButton) {
        
        let createHabitViewController = CreateTrackerViewController()
        
        if sender.tag == TrackerType.habit.rawValue {
            createHabitViewController.trackerType = .habit
        } else if sender.tag == TrackerType.event.rawValue {
            createHabitViewController.trackerType = .event
        }
        
        createHabitViewController.trackerCreated = { [weak self] newTracker in
            
            guard let self = self else { return }
            self.newTracker = newTracker
            guard let trackerCreated = self.trackerCreated else { return }
            trackerCreated(newTracker)
            self.dismiss(animated: false)
        }
        self.present(createHabitViewController, animated: true)
    }
}
