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
    
    // MARK: - View Life Cycles
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel?.nameBinding = nil
    }
}
