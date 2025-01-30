//
//  EmojiCollectionViewCell.swift
//  Tracker
//
//  Created by Nikolay on 24.12.2024.
//

import UIKit

class EmojiCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IB Outlets
    let emojiLabel = UILabel()

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        addEmojiLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycles
    override func prepareForReuse() {
        super.prepareForReuse()
        setSelectedStatus(selected: false)
    }
    
    // MARK: - Public Methods
    func configureCell(emoji: String) {
        emojiLabel.text = emoji
    }
    
    func setSelectedStatus(selected: Bool) {
        if selected {
            contentView.backgroundColor = UIColor(named: "CollectionSelectionColor")
            contentView.layer.cornerRadius = 16
        } else {
            contentView.backgroundColor = UIColor(named: "YPWhite")
            contentView.layer.cornerRadius = 0
        }
    }
    
    // MARK: - Private Methods
    private func addEmojiLabel() {
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emojiLabel)
        emojiLabel.heightAnchor.constraint(equalToConstant: 38).isActive = true
        emojiLabel.widthAnchor.constraint(equalToConstant: 32).isActive = true
        emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        emojiLabel.font = UIFont(name: "SF Pro Bold", size: 32)
        emojiLabel.textAlignment = .center
    }
}
