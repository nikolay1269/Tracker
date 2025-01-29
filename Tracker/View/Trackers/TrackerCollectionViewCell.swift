//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Nikolay on 09.12.2024.
//

import UIKit

final class TrackerCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IB Outlets
    let mainView = UIView()
    private let trackerNameLabel = UILabel()
    private let emojiLabel = UILabel()
    private let emojiContainerView = UIView()
    private let statusButton = UIButton()
    private var pinImageView: UIImageView?
    
    // MARK: - Public Properties
    var trackerStatusChanged: (() -> Void)?
    
    // MARK: - Private Properties
    private let daysCountLabel = UILabel()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        addMainView()
        addEmoji()
        addTrackerLabel()
        addStatusButton()
        addDaysCountLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycles
    override func prepareForReuse() {
        super.prepareForReuse()
        pinImageView?.image = nil
    }
    
    // MARK: - IB Actions
    @objc private func statusButtonTapped() {
        guard let trackerStatusChanged = trackerStatusChanged else { return }
        trackerStatusChanged()
    }
    
    // MARK: - Public Methods
    func configureCell(tracker: Tracker, status: Bool, daysCount: Int) {
        mainView.backgroundColor = tracker.color
        statusButton.backgroundColor = tracker.color
        trackerNameLabel.text = tracker.name
        emojiLabel.text = tracker.emoji
        let daysString = String.localizedStringWithFormat(NSLocalizedString("numberOfDays", comment: "Number of remaining days"), daysCount)
        daysCountLabel.text = String.localizedStringWithFormat(NSLocalizedString("daysCount", comment: "Correct form of 'word' day"), daysCount, daysString)
        changeStatus(isDone: status)
        if tracker.isPinned {
            if pinImageView == nil {
                addPinImageView()
            } else {
                pinImageView?.image = UIImage(named: "pin")
            }
        } else {
            pinImageView?.image = nil
        }
    }
    
    // MARK: - Private Methods
    private func addDaysCountLabel() {
        daysCountLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(daysCountLabel)
        daysCountLabel.text = "0 дней"
        daysCountLabel.font = UIFont(name: "SF Pro Medium", size: 12)
        daysCountLabel.numberOfLines = 0
        daysCountLabel.centerYAnchor.constraint(equalTo: statusButton.centerYAnchor).isActive = true
        daysCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12).isActive = true
        daysCountLabel.trailingAnchor.constraint(equalTo: statusButton.leadingAnchor).isActive = true
    }
    
    private func addStatusButton() {
        statusButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statusButton)
        statusButton.layer.cornerRadius = 17
        statusButton.tintColor = .systemBackground
        statusButton.heightAnchor.constraint(equalToConstant: 34).isActive = true
        statusButton.widthAnchor.constraint(equalToConstant: 34).isActive = true
        statusButton.topAnchor.constraint(equalTo: mainView.bottomAnchor, constant: 8).isActive = true
        statusButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16).isActive = true
        statusButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -12).isActive = true
        statusButton.addTarget(self, action: #selector(statusButtonTapped), for: .touchUpInside)
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
        emojiContainerView.layer.cornerRadius = 16
        
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
        trackerNameLabel.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 12).isActive = true
        trackerNameLabel.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -12).isActive = true
        trackerNameLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 8).isActive = true
    }
    
    private func addPinImageView() {
        pinImageView = UIImageView(image: UIImage(named: "pin"))
        guard let pinImageView = pinImageView  else {
            return
        }
        contentView.addSubview(pinImageView)
        pinImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pinImageView.heightAnchor.constraint(equalToConstant: 24),
            pinImageView.widthAnchor.constraint(equalToConstant: 24),
            pinImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            pinImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4)
        ])
    }
}
