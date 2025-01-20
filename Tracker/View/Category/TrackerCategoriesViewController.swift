//
//  TrackerCategoriesViewController.swift
//  Tracker
//
//  Created by Nikolay on 18.01.2025.
//

import UIKit

class TrackerCategoriesViewController: UIViewController {

    // MARK: - IB Outlets
    private lazy var trackerCategoriesTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TrackerCategoryTableViewCell.self, forCellReuseIdentifier: celldentifier)
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = UIColor(named: "YPGray")
        tableView.layer.cornerRadius = 16
        return tableView
    }()
    
    private lazy var trackerCategoriesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Категория"
        label.font = UIFont(name: "SF Pro Regular", size: 16)
        return label
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: "YPBlack")
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        let font = UIFont(name: "SF Pro Medium", size: 16) ?? UIFont.systemFont(ofSize: 16)
        let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : font,
                                                          NSAttributedString.Key.foregroundColor : UIColor.white]
        let attributedTitle = NSAttributedString(string: "Добавить категорию", attributes: attributes)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Public Properties
    var onTrackerCategorySelected: Binding<TrackerCategory?>?
    
    // MARK: - Private Properties
    private lazy var trackerCategoryStore: TrackerCategoryStoreProtocol? = {
        let context = CoreDataManager.shared.context
        let trackerCategoryStore = TrackerCategoryStore(context: context, date: Date(), delegate: self)
        return trackerCategoryStore
    }()
    
    private var emptyView: UIView?
    private let celldentifier = "cellIdentifier"
    private var selectedTrackerCategory: TrackerCategory?
    private var selectedIndexPath: IndexPath?
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        let categoryCount = trackerCategoryStore?.numberOfCategories() ?? 0
        changeEmptyViewVisibility(categoryCount == 0)
        if categoryCount > 0 && selectedTrackerCategory == nil {
            changeDoneButtonEnable(false)
        }
    }
    
    // MARK: - IB Actions
    @objc private func buttonTapped() {
        if selectedTrackerCategory != nil {
            onTrackerCategorySelected?(selectedTrackerCategory)
            dismiss(animated: true)
        } else if trackerCategoryStore?.numberOfCategories() == 0 {
            //TODO: Open create category screen
        }
    }
    
    // MARK: - Private Methods
    private func setupLayout() {
        
        view.backgroundColor = .white
        view.addSubview(trackerCategoriesTableView)
        view.addSubview(trackerCategoriesLabel)
        view.addSubview(doneButton)
        emptyView = EmptyView(rootView: view, parentView: trackerCategoriesTableView, text: "Привычки и события можно объединить по смыслу")
        NSLayoutConstraint.activate([
            trackerCategoriesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerCategoriesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackerCategoriesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            trackerCategoriesTableView.topAnchor.constraint(equalTo: trackerCategoriesLabel.bottomAnchor, constant: 14),
            
            trackerCategoriesLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 28),
            trackerCategoriesLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func changeEmptyViewVisibility(_ visible: Bool) {
        emptyView?.isHidden = !visible
    }
    
    private func changeDoneButtonEnable(_ enable: Bool) {
        doneButton.isEnabled = enable
        switch(enable) {
        case true:
            doneButton.backgroundColor = UIColor(named: "YPBlack")
        case false:
            doneButton.backgroundColor = UIColor(named: "YPGray")
        }
    }
}

// MARK: - TrackerCategoryStoreDelegate
extension TrackerCategoriesViewController: TrackerCategoryStoreDelegate {
    
    func didUpdate() {
        trackerCategoriesTableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension TrackerCategoriesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackerCategoryStore?.numberOfCategories() ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: celldentifier, for: indexPath) as? TrackerCategoryTableViewCell else {
            return UITableViewCell()
        }
        
        let category = trackerCategoryStore?.category(at: indexPath)
        cell.textLabel?.text = category?.name
        //cell.label.text = category?.name
        cell.accessoryType = .none
        cell.backgroundColor = UIColor(named: "TextFieldBackgroundColor")
        cell.selectionStyle = .none
        if indexPath.row == (trackerCategoryStore?.numberOfCategories() ?? 0) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.size.width)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TrackerCategoriesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let selectedIndexPath = selectedIndexPath {
            let previousSelectedCell = tableView.cellForRow(at: selectedIndexPath)
            previousSelectedCell?.accessoryType = .none
        }
        selectedTrackerCategory = trackerCategoryStore?.category(at: indexPath)
        if selectedTrackerCategory != nil {
            changeDoneButtonEnable(true)
        }
        let selectedCell = tableView.cellForRow(at: indexPath)
        selectedCell?.accessoryType = .checkmark
        selectedIndexPath = indexPath
    }
}
