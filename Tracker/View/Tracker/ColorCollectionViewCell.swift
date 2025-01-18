//
//  ColorCollectionViewCell.swift
//  Tracker
//
//  Created by Nikolay on 24.12.2024.
//

import UIKit

class ColorCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IB Outlets
    let colorView = UIView()
    
    // MARK: - Private Properties
    private var currentColor: UIColor?

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        addColorView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods
    func configureCell(color: UIColor) {
        currentColor = color
        colorView.backgroundColor = color
    }
    
    func setSelectedStatus(selected: Bool) {
        if selected {
            contentView.layer.borderWidth = 3
            let transparentColor = currentColor?.withAlphaComponent(0.3)
            contentView.layer.borderColor = transparentColor?.cgColor
            contentView.layer.cornerRadius = 8
        } else {
            contentView.layer.borderWidth = 0
            contentView.layer.borderColor = UIColor(named: "YPWhite")?.cgColor
            contentView.layer.cornerRadius = 0
        }
    }

    // MARK: - Private Methods
    private func addColorView() {
        colorView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(colorView)
        colorView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        colorView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        colorView.layer.cornerRadius = 8
    }
}
