//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Nikolay on 27.01.2025.
//

import UIKit

enum TrackerFilter: Int {
    case all
    case today
    case completed
    case notcompleted
}

class FiltersViewController: UIViewController {
    
    // MARK: - Public Properties
    var filterSelected: ((TrackerFilter) -> Void)?
    var currentFilter: TrackerFilter = .all
    
    // MARK: - Private Properties
    private let cellIdentifier = "Cell"

    // MARK: - IB Outlets
    private lazy var filtersTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 75
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor(named: "YPGray")
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return tableView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("Filters", comment: "Filters screen title")
        label.textAlignment = .center
        label.font = UIFont(name: "SF Pro Medium", size: 16)
        return label
    }()
    
    private let filters = [NSLocalizedString("All trackers", comment: "Filters"),
                           NSLocalizedString("Trackers for today", comment: "Filters"),
                           NSLocalizedString("Completed", comment: "Filters"),
                           NSLocalizedString("Not completed", comment: "Filters")]
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Private Methods
    private func configureUI() {
        view.backgroundColor = .white
        view.addSubview(filtersTableView)
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            filtersTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filtersTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            filtersTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            filtersTableView.heightAnchor.constraint(equalToConstant: 300),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 28)
        ])
        filtersTableView.performBatchUpdates({}, completion: { [weak self] isCompeleted in
            guard let self = self else { return }
            if isCompeleted {
                let filterRow = self.currentFilter.rawValue
                let filterIndexPath = IndexPath(row: filterRow, section: 0)
                let cell = self.filtersTableView.cellForRow(at: filterIndexPath)
                cell?.accessoryType = .checkmark
            }
        })
        
    }
}

// MARK: - UITableViewDataSource
extension FiltersViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = filters[indexPath.row]
        cell.accessoryType = .none
        cell.backgroundColor = UIColor(named: "TextFieldBackgroundColor")
        cell.selectionStyle = .none
        if indexPath.row == filters.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.size.width)
        } else {
            cell.separatorInset = UIEdgeInsets.zero
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension FiltersViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let filter = TrackerFilter(rawValue: indexPath.row) ?? .all
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        dismiss(animated: true)
        filterSelected?(filter)
    }
}
