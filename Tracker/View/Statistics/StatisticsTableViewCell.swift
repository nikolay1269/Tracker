//
//  StatisticsTableViewCell.swift
//  Tracker
//
//  Created by Nikolay on 28.01.2025.
//

import UIKit

class StatisticsTableViewCell: UITableViewCell {
    
    // MARK: - IB Outlets
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "SF Pro Bold", size: 34)
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "SF Pro Medium", size: 12)
        return label
    }()
    
    // MARK: - Private Properties
    private let colors = [UIColor.colorFromHex(hex: "#007BFA"),
                          UIColor.colorFromHex(hex: "#46E69D"),
                          UIColor.colorFromHex(hex: "#FD4C49")]

    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func configureCell(value: Int, description: String) {
        valueLabel.text = "\(value)"
        descriptionLabel.text = description
    }
    
    // MARK: - Private Methods
    private func configureUI() {
        contentView.addSubview(valueLabel)
        contentView.addSubview(descriptionLabel)
        NSLayoutConstraint.activate([
            valueLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 12),
            valueLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 12),
            descriptionLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 7)
        ])
        makeGradient()
    }
    
    private func makeGradient() {
        let cornerRadius: CGFloat = 16
        let lineWidth: CGFloat = 1
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: UIScreen.main.bounds.width - 16 * 2, height: 90))
        gradient.colors = colors.map({ (color) -> CGColor in
            color.cgColor
        })
        
        gradient.startPoint = CGPoint(x: 0, y: 1)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        
        let shape = CAShapeLayer()
        shape.lineWidth = lineWidth
        let rect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 16 * 2, height: 90)
        shape.path = UIBezierPath(roundedRect: rect.insetBy(dx: lineWidth,
                                                            dy: lineWidth), cornerRadius: cornerRadius).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        
        self.layer.addSublayer(gradient)
    }
}
