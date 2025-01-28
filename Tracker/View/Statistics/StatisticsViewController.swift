//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Nikolay on 30.11.2024.
//

import UIKit

class StatisticsViewController: UIViewController {
    
    // MARK: - IB Outlets
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("Statistics", comment: "Title of statistics screen")
        label.textColor = .black
        label.font = UIFont(name: "SF Pro Bold", size: 34)
        return label
    }()
    
    private lazy var filtersTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(StatisticsTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.rowHeight = 90
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .singleLine
        return tableView
    }()
    
    private lazy var trackerRecordStore = {
        let context = CoreDataManager.shared.context
        let trackerRecordStore = TrackerRecordStore(context: context)
        return trackerRecordStore
    }()
    
    // MARK: - Private Properties
    private let cellIdentifier = "Cell"
    private let descriptions = [NSLocalizedString("Trackers completed", comment: "")]
    private var values: [Int] = []
    private var emptyView: EmptyView?

    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        loadStatistics()
    }
    
    // MARK: - Private Methods
    private func configureUI() {
        view.backgroundColor = .white
        view.addSubview(titleLabel)
        view.addSubview(filtersTableView)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            filtersTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filtersTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            filtersTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filtersTableView.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 77)
        ])
        emptyView = EmptyView(rootView: view,
                              parentView: filtersTableView,
                              text: NSLocalizedString("There is nothing to analyze yet", comment: "Empty categories screen text"),
                              imageName: "FiltersEmptyScreen")
    }
    
    private func loadStatistics() {
        let trackersCompleted = trackerRecordStore.numberOfCompletedTrackers()
        if trackersCompleted > 0 {
            values.append(trackersCompleted)
            emptyView?.isHidden = true
        } else {
            emptyView?.isHidden = false
        }
    }
}

// MARK: - UITableViewDataSource
extension StatisticsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return values.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? StatisticsTableViewCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.configureCell(value: values[indexPath.row], description: descriptions[indexPath.row])
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        cell.layoutSubviews()
        return cell
    }
}
