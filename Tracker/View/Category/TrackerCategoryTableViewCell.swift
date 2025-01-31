//
//  TrackerCategoryTableViewCell.swift
//  Tracker
//
//  Created by Nikolay on 19.01.2025.
//

import UIKit

final class TrackerCategoryTableViewCell: UITableViewCell {
    
    // MARK: - Public Properties
    var viewModel: TrackerCategoryViewModel? {
        didSet {
            viewModel?.nameBinding = { [weak self] name in
                self?.textLabel?.text = name
            }
        }
    }
    
    static let celldentifier = "cellIdentifier"
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .none
        backgroundColor = UIColor(named: "TextFieldBackgroundColor")
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycles
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel?.nameBinding = nil
    }
    
    // MARK: - Public Methods
    func configureInsets(hide: Bool) {
        if hide {
            self.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: self.contentView.bounds.size.width)
        } else {
            self.separatorInset = UIEdgeInsets.zero
        }
    }
}
