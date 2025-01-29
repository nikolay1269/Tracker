//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Nikolay on 28.11.2024.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - IB Outlets
    private var plusButton: UIButton?
    private var dateTimeLabel: UILabel?
    private var trackersLabel: UILabel?
    private var collectionView: UICollectionView?
    private var emptyView: UIView?
    private var emptyImageView: UIImageView?
    private var searchTextField: UISearchTextField?
    private var filterButton: UIButton?
    private var datePicker: UIDatePicker?
    
    // MARK: - Public Properties
    var currentDate: Date = Date()
    
    // MARK: - Private Properties
    private let cellIdentifier = "trackCellIdentifier"
    private let headerIdentifier = "headerIdentifier"
    private var currentFilter: TrackerFilter = .all
    private lazy var trackerStore: TrackerStoreProtocol? = {
        let context = CoreDataManager.shared.context
        let trackerStore = TrackerStore(context: context)
        return trackerStore
    }()
    private lazy var trackerCategoryStore: TrackerCategoryStoreProtocol? = {
        let context = CoreDataManager.shared.context
        let trackerCategoryStore = TrackerCategoryStore(context: context, date: Date(), delegate: self)
        return trackerCategoryStore
    }()
    private lazy var trackerRecordStore: TrackerRecordStoreProtocol? = {
        let context = CoreDataManager.shared.context
        let trackerRecordStore = TrackerRecordStore(context: context)
        return trackerRecordStore
    }()

    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.shared.backgroundColor
        addLeftNavigationBarItem()
        addTrackersLabel()
        addSearchTextField()
        addFilterButton()
        addCollectionView()
        addEmptyView()
        addDateTimePicker()
        changeEmptyViewAndFilterButtonVisibility()
        collectionView?.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticService.shared.sendOpenEvent(screen: .main)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnalyticService.shared.sendCloseEvent(screen: .main)
    }
    
    // MARK: - IB Actions
    @objc private func filtersButtonTapped() {
        let filtersViewController = FiltersViewController()
        filtersViewController.currentFilter = currentFilter
        filtersViewController.filterSelected = { [weak self] filter in
            guard let self = self else { return }
            self.currentFilter = filter
            self.trackerCategoryStore?.setCurrentFilter(filter: filter)
            switch(filter) {
            case .today:
                self.currentFilter = .all
                self.currentDate = Date()
                self.datePicker?.setDate(self.currentDate, animated: true)
                self.handleCurrentDate()
            default:
                break
            }
            self.collectionView?.reloadData()
            self.changeEmptyViewAndFilterButtonVisibility()
        }
        AnalyticService.shared.sendClickEvent(screen: .main, item: .filter)
        present(filtersViewController, animated: true)
    }
    
    @objc private func plusButtonTapped() {
        let selectTrackerTypeViewController = SelectTrackerTypeViewController()
        selectTrackerTypeViewController.trackerCreated = { [weak self] newTracker, trackerCategory in
            
            guard let self = self else { return }
            self.addNewTracker(tracker: newTracker, trackerCategory: trackerCategory)
            self.changeEmptyViewAndFilterButtonVisibility()
            self.collectionView?.reloadData()
        }
        AnalyticService.shared.sendClickEvent(screen: .main, item: .add_track)
        self.present(selectTrackerTypeViewController, animated: true)
    }
    
    @objc private func datePickerValueChange(_ sender: UIDatePicker) {
        currentDate = sender.date
        handleCurrentDate()
    }
    
    @objc private func searchTextFieldValueChanged() {
        trackerCategoryStore?.setSearchText(text: searchTextField?.text ?? "")
        collectionView?.reloadData()
        changeEmptyViewAndFilterButtonVisibility()
    }
    
    // MARK: - Public Methods
    func handleCurrentDate() {
        trackerCategoryStore?.setCurrentDate(date: currentDate)
        changeEmptyViewAndFilterButtonVisibility()
        collectionView?.reloadData()
    }
    
    // MARK: - Private Methods
    private func addFilterButton() {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        let font = UIFont(name: "SF Pro Medium", size: 16) ?? UIFont.systemFont(ofSize: 16)
        let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : font,
                                                          NSAttributedString.Key.foregroundColor : UIColor.white]
        let attributedTitle = NSAttributedString(string: NSLocalizedString("Filters", comment: "Filters button title"), attributes: attributes)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        button.backgroundColor = UIColor(named: "YPBlue")
        button.layer.cornerRadius = 16
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.widthAnchor.constraint(equalToConstant: 114).isActive = true
        button.addTarget(self, action: #selector(filtersButtonTapped), for: .touchUpInside)
        filterButton = button
    }
    
    private func addLeftNavigationBarItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(plusButtonTapped))
        navigationItem.leftBarButtonItem?.tintColor = .label
    }
    
    private func addNewTracker(tracker: Tracker, trackerCategory: TrackerCategory) {
        do {
            try trackerStore?.addRecord(tracker, categoryId: trackerCategory.id)
        } catch let error {
            print(error)
        }
    }
    
    private func updateTracker(tracker: Tracker, trackerCategory: TrackerCategory) {
        do {
            try trackerStore?.updateRecord(tracker, categoryId: trackerCategory.id)
        } catch let error {
            print(error)
        }
    }
    
    private func deleteTracker(tracker: Tracker) {
        do {
            try trackerStore?.deleteRecord(tracker)
        } catch let error {
            print(error)
        }
    }
    
    private func addDateTimePicker() {
        let datePicker = UIDatePicker()
        datePicker.date = currentDate
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale.current
        datePicker.calendar.firstWeekday = 2
        datePicker.layer.cornerRadius = 8
        let datePickerBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.rightBarButtonItem = datePickerBarButtonItem
        let currentDate = Date()
        let calendar = Calendar.current
        let minDate = calendar.date(byAdding: .year, value: -10, to: currentDate)
        let maxDate = currentDate
        datePicker.minimumDate = minDate
        datePicker.maximumDate = maxDate
        datePicker.addTarget(self, action: #selector(datePickerValueChange(_:)), for: .valueChanged)
        datePicker.widthAnchor.constraint(equalToConstant: 100).isActive = true
        self.datePicker = datePicker
    }
    
    private func addTrackersLabel() {
        let trackersLabel = UILabel()
        trackersLabel.translatesAutoresizingMaskIntoConstraints = false
        trackersLabel.text = NSLocalizedString("Trackers", comment: "Title of main screen")
        trackersLabel.font = UIFont(name: "SF Pro Bold", size: 34)
        view.addSubview(trackersLabel)
        trackersLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive  = true
        trackersLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 88).isActive = true
        self.trackersLabel = trackersLabel
    }
    
    private func addSearchTextField() {
        let searchTextField = UISearchTextField()
        searchTextField.backgroundColor = UIColor(named: "SearchColor")
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchTextField)
        searchTextField.textColor = .label
        searchTextField.font = UIFont(name: "SF Pro Regular", size: 17)
        searchTextField.layer.cornerRadius = 10
        searchTextField.heightAnchor.constraint(equalToConstant: 36).isActive = true
        searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        if let trackersLabel = trackersLabel {
            searchTextField.topAnchor.constraint(equalTo: trackersLabel.bottomAnchor, constant: 10).isActive = true
        }
        
        let attributes = [NSAttributedString.Key.foregroundColor : UIColor(named: "YPGray") ?? .gray]
        let attributePlacedHolder = NSAttributedString(string: NSLocalizedString("Search", comment: "Search field placehodler"), attributes: attributes)
        searchTextField.attributedPlaceholder = attributePlacedHolder
        searchTextField.addTarget(self, action: #selector(searchTextFieldValueChanged), for: .editingChanged)
        self.searchTextField = searchTextField
    }
    
    private func addCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        if let searchTextField = searchTextField {
            collectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 5).isActive = true
        }
        if let filterButton = filterButton {
            collectionView.bottomAnchor.constraint(equalTo: filterButton.topAnchor).isActive = true
        }
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = Colors.shared.backgroundColor
        self.collectionView = collectionView
    }
    
    private func addEmptyView() {
        
        guard let collectionView = collectionView else { return }
        
        let emptyView = UIView()
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyView)
        emptyView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor).isActive = true
        emptyView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor).isActive = true
        emptyView.topAnchor.constraint(equalTo: collectionView.topAnchor).isActive = true
        emptyView.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor).isActive = true
        let imageView = UIImageView(image: UIImage(named: "TrackersEmptyScreen"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        emptyView.addSubview(imageView)
        emptyImageView = imageView
        imageView.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("What will we monitor?", comment: "Empty view text")
        label.font = UIFont(name: "SF Pro Medium", size: 12)
        label.textAlignment = .center
        emptyView.addSubview(label)
        label.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
        self.emptyView = emptyView
    }
    
    private func changeEmptyViewAndFilterButtonVisibility() {
        let numberOfFilteredItems = trackerCategoryStore?.numberOfItems(filter: currentFilter, searchText: searchTextField?.text) ?? 0
        let numberOfItemsWithoutFilters = trackerCategoryStore?.numberOfItems(filter: .all, searchText: nil) ?? 0
        if numberOfItemsWithoutFilters == 0 {
            emptyView?.isHidden = false
            emptyImageView?.image = UIImage(named: "TrackersEmptyScreen")
            filterButton?.isHidden = true
        } else if numberOfFilteredItems == 0 && numberOfItemsWithoutFilters > 0 {
            emptyView?.isHidden = false
            emptyImageView?.image = UIImage(named: "FiltersEmptyScreen")
            filterButton?.isHidden = false
        } else if numberOfFilteredItems > 0 {
            emptyView?.isHidden = true
            filterButton?.isHidden = false
        }
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return trackerCategoryStore?.numberOfSections ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return trackerCategoryStore?.numbersOfFilteredTrackersInSection(section) ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }
        guard let tracker = try? trackerCategoryStore?.filteredTracker(at: indexPath) else {
            return UICollectionViewCell()
        }
        updateCellStatusAndDayCount(cell: cell, tracker: tracker)
        cell.trackerStatusChanged = { [weak self] in
            guard let self = self else { return }
            let isCompleted = self.trackerRecordStore?.isTrackerCompetedForDate(tracker: tracker, date: self.currentDate) ?? false
            if isCompleted {
                self.trackerRecordStore?.removeRecordForTracker(tracker, date: self.currentDate)
            } else {
                self.trackerRecordStore?.addRecordForTracker(tracker, date: self.currentDate)
            }
            self.updateCellStatusAndDayCount(cell: cell, tracker: tracker)
        }
        return cell
    }
    
    private func updateCellStatusAndDayCount(cell: TrackerCollectionViewCell, tracker: Tracker) {
        let status = trackerRecordStore?.isTrackerCompetedForDate(tracker: tracker, date: currentDate) ?? false
        let daysCount = trackerRecordStore?.trackerCompletedCount(tracker) ?? 0
        cell.configureCell(tracker: tracker, status: status, daysCount: daysCount)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier, for: indexPath) as? SupplementaryView else { return UICollectionReusableView() }
        view.titleLabel.text = trackerCategoryStore?.titleForSection(indexPath.section)
        return view
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: 167, height: 148)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: 45)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        
        guard let firstIndexPath = indexPaths.first,
              var tracker = try? trackerCategoryStore?.filteredTracker(at: firstIndexPath),
              let category = trackerCategoryStore?.filteredCategory(at: firstIndexPath)
        else
        {
            return nil
        }
        
        let contextMenuConfiguration = UIContextMenuConfiguration(identifier: nil, previewProvider: { [weak self] in self?.makePreview(indexPath: firstIndexPath) }) { (action) -> UIMenu? in
            
            let pinTitle = NSLocalizedString("Pin", comment: "Tracker context pin menu item")
            let pin = UIAction(title: pinTitle) { [weak self] _ in
                guard let self = self else { return }
                tracker = Tracker(id: tracker.id,
                                  name: tracker.name,
                                  color: tracker.color,
                                  emoji: tracker.emoji,
                                  schedule: tracker.schedule,
                                  isPinned: true)
                self.updateTracker(tracker: tracker, trackerCategory: category)
                self.collectionView?.reloadData()
            }
                
            let unpinTitle = NSLocalizedString("Unpin", comment: "Tracker context unpin menu item")
            let unpin = UIAction(title: unpinTitle) { [weak self] _ in
                guard let self = self else { return }
                tracker = Tracker(id: tracker.id,
                                  name: tracker.name,
                                  color: tracker.color,
                                  emoji: tracker.emoji,
                                  schedule: tracker.schedule,
                                  isPinned: false)
                self.updateTracker(tracker: tracker, trackerCategory: category)
                self.collectionView?.reloadData()
            }
                
            let editTitle = NSLocalizedString("Edit", comment: "Tracker context edit menu item")
            let edit = UIAction(title: editTitle) { [weak self] _ in
                guard let self = self else { return }
                let createTrackerViewController = CreateTrackerViewController()
                createTrackerViewController.mode = .edit
                createTrackerViewController.currentTracker = tracker
                createTrackerViewController.selectedTrackerCategory = category
                createTrackerViewController.trackerCreated = { [weak self] newTracker, trackerCategory in
                    guard let self = self else { return }
                    self.updateTracker(tracker: newTracker, trackerCategory: trackerCategory)
                    self.collectionView?.reloadData()
                }
                let daysCount = self.trackerRecordStore?.trackerCompletedCount(tracker) ?? 0
                createTrackerViewController.daysCount = daysCount
                if tracker.schedule.count > 0 {
                    createTrackerViewController.trackerType = .habit
                } else {
                    createTrackerViewController.trackerType = .event
                }
                AnalyticService.shared.sendClickEvent(screen: .main, item: .edit)
                self.present(createTrackerViewController, animated: true)
            }
            
            let deleteTitle = NSLocalizedString("Delete", comment: "Tracker context delete menu item")
            let delete = UIAction(title: deleteTitle, attributes: .destructive) { [weak self] _ in
                let title = NSLocalizedString("Are you sure you want to remove the tracker?", comment: "Title of delete action sheet")
                let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
                let deleteTitle = NSLocalizedString("Delete", comment: "")
                alert.addAction(UIAlertAction(title: deleteTitle, style: .destructive , handler: { [weak self] (UIAlertAction) in
                    guard let self = self else { return }
                    self.deleteTracker(tracker: tracker)
                    self.changeEmptyViewAndFilterButtonVisibility()
                }))
                let cancelTitle = NSLocalizedString("Cancel", comment: "")
                alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel , handler: { (UIAlertAction) in
                    alert.dismiss(animated: true)
                }))
                AnalyticService.shared.sendClickEvent(screen: .main, item: .delete)
                self?.present(alert, animated: true)
            }
            
            if !tracker.isPinned {
                return UIMenu(options: UIMenu.Options.displayInline, children: [pin, edit, delete])
            } else {
                return UIMenu(options: UIMenu.Options.displayInline, children: [unpin, edit, delete])
            }
        }
        return contextMenuConfiguration
    }
    
    private func makePreview(indexPath: IndexPath) -> UIViewController {
        let vc = UIViewController()
        guard let currentCell = collectionView?.cellForItem(at: indexPath) as? TrackerCollectionViewCell else {
            return vc
        }
        let renderer = UIGraphicsImageRenderer(size: currentCell.mainView.bounds.size)
        let image = renderer.image { ctx in
            currentCell.mainView.drawHierarchy(in: currentCell.mainView.bounds, afterScreenUpdates: true)
        }
        let imageView = UIImageView(image: image)
        vc.view = imageView
        vc.preferredContentSize = imageView.frame.size
        return vc
    }
}

extension TrackersViewController: TrackerCategoryStoreDelegate {
    
    func didUpdate() {
        collectionView?.reloadData()
        changeEmptyViewAndFilterButtonVisibility()
    }
}
