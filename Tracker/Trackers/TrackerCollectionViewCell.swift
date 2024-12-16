//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Nikolay on 09.12.2024.
//

import UIKit

final class TrackerCollectionViewCell: UICollectionViewCell {
    
    let trackerNameLabel = UILabel()
    let emojiLabel = UILabel()
    let emojiContainerView = UIView()
    let statusButton = UIButton()
    let mainView = UIView()
    let daysCountLabel = UILabel()
    var isDone = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.borderColor = UIColor.black.cgColor
        contentView.layer.borderWidth = 1
        addMainView()
        addEmoji()
        addTrackerLabel()
        addPlusButton()
        addDaysCountLabel()
    }
    
    private func addDaysCountLabel() {
        daysCountLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(daysCountLabel)
        daysCountLabel.text = "0 дней"
        daysCountLabel.font = UIFont(name: "SF Pro Regualr", size: 12)
        daysCountLabel.numberOfLines = 0
        daysCountLabel.centerYAnchor.constraint(equalTo: statusButton.centerYAnchor).isActive = true
        daysCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12).isActive = true
        daysCountLabel.trailingAnchor.constraint(equalTo: statusButton.leadingAnchor).isActive = true
    }
    
    private func addPlusButton() {
        statusButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statusButton)
        statusButton.layer.cornerRadius = 17
        changeStatus(isDone: isDone)
        statusButton.tintColor = UIColor(named: "YPWhite")
        statusButton.heightAnchor.constraint(equalToConstant: 34).isActive = true
        statusButton.widthAnchor.constraint(equalToConstant: 34).isActive = true
        statusButton.topAnchor.constraint(equalTo: mainView.bottomAnchor, constant: 8).isActive = true
        statusButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16).isActive = true
        statusButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -12).isActive = true
        statusButton.addTarget(self, action: #selector(statusButtonTapped), for: .touchUpInside)
    }
    
    @objc private func statusButtonTapped() {
        
        changeStatus(isDone: !isDone)
        isDone = !isDone
    }
    
    private func changeStatus(isDone: Bool) {
        switch(isDone) {
        case true:
            statusButton.setImage(UIImage(named: "done_white"), for: .normal)
            statusButton.alpha = 0.3
        case false:
            statusButton.setImage(UIImage(named: "plus_black")?.withRenderingMode(.alwaysTemplate), for: .normal)
            statusButton.alpha = 1
        }
    }
    
    private func addEmoji() {
        
        emojiContainerView.translatesAutoresizingMaskIntoConstraints = false
        mainView.addSubview(emojiContainerView)
        
        mainView.addSubview(emojiLabel)
        emojiContainerView.heightAnchor.constraint(equalToConstant: 28).isActive = true
        emojiContainerView.widthAnchor.constraint(equalToConstant: 28).isActive = true
        emojiContainerView.leftAnchor.constraint(equalTo: mainView.leftAnchor, constant: 12).isActive = true
        emojiContainerView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 12).isActive = true
        emojiContainerView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3)
        emojiContainerView.layer.masksToBounds = true
        emojiContainerView.layer.cornerRadius = 15
        
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiContainerView.addSubview(emojiLabel)
        emojiLabel.textAlignment = .center
        emojiLabel.font = UIFont(name: "SF Pro Regualr", size: 16)
        emojiLabel.heightAnchor.constraint(equalToConstant: 22).isActive = true
        emojiLabel.widthAnchor.constraint(equalToConstant: 22).isActive = true
        emojiLabel.leftAnchor.constraint(equalTo: emojiContainerView.leftAnchor, constant: 3).isActive = true
        emojiLabel.topAnchor.constraint(equalTo: emojiContainerView.topAnchor, constant: 3).isActive = true
        emojiLabel.rightAnchor.constraint(equalTo: emojiContainerView.rightAnchor, constant: -3).isActive = true
        emojiLabel.bottomAnchor.constraint(equalTo: emojiContainerView.bottomAnchor, constant: -3).isActive = true
    }
    
    private func addMainView() {
        
        mainView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainView)
        mainView.layer.cornerRadius = 16
        mainView.heightAnchor.constraint(equalToConstant: 90).isActive = true
        mainView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        mainView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        mainView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
    }
    
    private func addTrackerLabel() {
        trackerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        trackerNameLabel.numberOfLines = 0
        trackerNameLabel.lineBreakMode = .byWordWrapping
        trackerNameLabel.textAlignment = .left
        trackerNameLabel.textColor = UIColor(named: "YPWhite")
        mainView.addSubview(trackerNameLabel)
        trackerNameLabel.font = UIFont(name: "SF Pro Medium", size: 12)
        trackerNameLabel.textColor = UIColor(named: "TextColor")
        trackerNameLabel.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 12).isActive = true
        trackerNameLabel.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: 12).isActive = true
        trackerNameLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 8).isActive = true
    }
    
    func configureCell(tracker: Tracker) {
        mainView.backgroundColor = tracker.color
        statusButton.backgroundColor = tracker.color
        trackerNameLabel.text = tracker.name
        emojiLabel.text = tracker.emoji
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
