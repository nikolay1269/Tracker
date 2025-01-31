//
//  TrackerCategoriesViewController.swift
//  Tracker
//
//  Created by Nikolay on 18.01.2025.
//

import UIKit

final class TrackerCategoriesViewController: UIViewController {

    // MARK: - IB Outlets
    private lazy var trackerCategoriesTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TrackerCategoryTableViewCell.self, forCellReuseIdentifier: TrackerCategoryTableViewCell.celldentifier)
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = UIColor(named: "YPGray")
        tableView.layer.cornerRadius = 16
        tableView.rowHeight = 75
        return tableView
    }()
    
    private lazy var trackerCategoriesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("Category", comment: "Categories screen title")
        label.font = UIFont(name: "SF Pro Medium", size: 16)
        return label
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: "YPBlack")
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        let font = UIFont(name: "SF Pro Medium", size: 16) ?? UIFont.systemFont(ofSize: 16)
        let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : font,
                                                          NSAttributedString.Key.foregroundColor : UIColor.white]
        let attributedTitle = NSAttributedString(string: NSLocalizedString("Add category", comment: "Create category button title"), attributes: attributes)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Public Properties
    var viewModel: TrackerCategoriesViewModel
    var selectedCategory: TrackerCategory?
    var mode: ScreenMode?
    
    // MARK: - Private Properties
    private var emptyView: UIView?
    
    init(viewModel: TrackerCategoriesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        let categoryCount = viewModel.numberOfCategories()
        changeEmptyViewVisibility(categoryCount == 0)
        configureBindgins()
        selectCurrentCategoryInTableView()
    }
    
    // MARK: - IB Actions
    @objc private func addCategoryButtonTapped() {

        let createTrackerCategoryViewController = CreateTrackerCategoryViewController(viewModel: viewModel)
        self.present(createTrackerCategoryViewController, animated: true)
    }
    
    // MARK: - Private Methods
    private func configureBindgins() {
        viewModel.trackerCategoryViewModelsBinding = { [weak self] _ in
            guard let self = self else { return }
            self.trackerCategoriesTableView.reloadData()
            let categoryCount = self.viewModel.numberOfCategories()
            self.changeEmptyViewVisibility(categoryCount == 0)
        }
    }
    
    private func selectCurrentCategoryInTableView() {
        trackerCategoriesTableView.performBatchUpdates({}, completion: { isCompleted in
            if isCompleted {
                if let selectedCategory = self.selectedCategory {
                    let selectedCategoryIndex = self.viewModel.getNumberOfCategory(category: selectedCategory)
                    let cell = self.trackerCategoriesTableView.cellForRow(at: IndexPath(row: selectedCategoryIndex, section: 0))
                    cell?.accessoryType = .checkmark
                }
            }
        })
    }
    
    private func setupLayout() {
        
        view.backgroundColor = .white
        view.addSubview(trackerCategoriesTableView)
        view.addSubview(trackerCategoriesLabel)
        emptyView = EmptyView(rootView: view,
                              parentView: trackerCategoriesTableView,
                              text: NSLocalizedString("Habits and events can be combined by meaning", comment: "Empty categories screen text"),
                              imageName: "TrackersEmptyScreen")
        view.addSubview(addCategoryButton)
        NSLayoutConstraint.activate([
            trackerCategoriesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerCategoriesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackerCategoriesTableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -14),
            trackerCategoriesTableView.topAnchor.constraint(equalTo: trackerCategoriesLabel.bottomAnchor, constant: 14),
            
            trackerCategoriesLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 28),
            trackerCategoriesLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func changeEmptyViewVisibility(_ isVisible: Bool) {
        emptyView?.isHidden = !isVisible
    }
}

// MARK: - UITableViewDataSource
extension TrackerCategoriesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCategories()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackerCategoryTableViewCell.celldentifier,
                                                       for: indexPath) as? TrackerCategoryTableViewCell else {
            return UITableViewCell()
        }
        
        let trackerCategoryViewModel = viewModel.tracketCategoryViewModelAt(indexPath)
        cell.viewModel = trackerCategoryViewModel
        let isLastRow = indexPath.row == (viewModel.numberOfCategories()) - 1
        cell.configureInsets(hide: isLastRow)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TrackerCategoriesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedCell = tableView.cellForRow(at: indexPath)
        selectedCell?.accessoryType = .checkmark
        viewModel.selectTrackerCategoryTappedAt(indexPath)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        var corners: UIRectCorner = []
        if indexPath.row == viewModel.numberOfCategories() - 1 {
            corners.update(with: .bottomLeft)
            corners.update(with: .bottomRight)
        }
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: cell.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: 16, height: 16)).cgPath
        cell.layer.mask = maskLayer
    }
}
