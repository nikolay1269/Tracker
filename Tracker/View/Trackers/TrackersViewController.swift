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
    private var searchTextField: UISearchTextField?
    
    // MARK: - Private Properties
    private var categories: [TrackerCategory] = []
    private let cellIdentifier = "trackCellIdentifier"
    private let headerIdentifier = "headerIdentifier"
    private var currentDate: Date = Date()
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
        view.backgroundColor = .white
        addLeftNavigationBarItem()
        addTrackersLabel()
        addSearchTextField()
        addCollectionView()
        addEmptyView()
        addDateTimePicker()
        generateTestData()
        let show = trackerCategoryStore?.numberOfItems() == 0
        changeEmptyStateForCollectionView(show: show)
        collectionView?.reloadData()
    }
    
    // MARK: - IB Actions
    @objc private func plusButtonTapped() {
        let selectTrackerTypeViewController = SelectTrackerTypeViewController()
        selectTrackerTypeViewController.trackerCreated = { [weak self] newTracker in
            
            guard let self = self else { return }
            self.addNewTracker(tracker: newTracker)
            self.collectionView?.reloadData()
        }
        self.present(selectTrackerTypeViewController, animated: true)
    }
    
    @objc private func datePickerValueChange(_ sender: UIDatePicker) {
        currentDate = sender.date
        trackerCategoryStore?.setCurrentDate(date: currentDate)
        let itemsNumber = trackerCategoryStore?.numberOfItems() ?? 0
        changeEmptyStateForCollectionView(show: itemsNumber == 0)
        collectionView?.reloadData()
    }
    
    @objc private func searchTextFieldValueChanged() {
        trackerCategoryStore?.setSearchText(text: searchTextField?.text ?? "")
        collectionView?.reloadData()
    }
    
    // MARK: - Private Methods
    private func generateTestData() {
        
        guard let trackerCategory = trackerCategoryStore?.getDefaultCategory() else {
            let trackerCategory = TrackerCategory(id: UUID(), name: "Важное", trackers: [])
            categories = [trackerCategory]
            do {
                try trackerCategoryStore?.addRecord(trackerCategory)
            } catch {
                print(error)
            }
            return
        }
        categories = [trackerCategory]
    }
    
    private func addLeftNavigationBarItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(plusButtonTapped))
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    private func addNewTracker(tracker: Tracker) {

        let oldCategory = categories.first
        var newTrackers = oldCategory?.trackers
        newTrackers?.append(tracker)
        guard let newTrackers = newTrackers, let oldCategory = oldCategory else { return }
        let newCategory = TrackerCategory(id: oldCategory.id, name: oldCategory.name, trackers: newTrackers)
        categories = [newCategory]
        do {
            try trackerStore?.addRecord(tracker, categoryId: newCategory.id)
        } catch let error {
            print(error)
        }
    }
    
    private func addDateTimePicker() {
        let datePicker = UIDatePicker()
        datePicker.date = currentDate
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_Ru")
        datePicker.calendar.firstWeekday = 2
        datePicker.overrideUserInterfaceStyle = .light
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
    }
    
    private func addTrackersLabel() {
        let trackersLabel = UILabel()
        trackersLabel.translatesAutoresizingMaskIntoConstraints = false
        trackersLabel.text = "Трекеры"
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
        searchTextField.textColor = UIColor(named: "YPBlack")
        searchTextField.font = UIFont(name: "SF Pro Regular", size: 17)
        searchTextField.layer.cornerRadius = 10
        searchTextField.heightAnchor.constraint(equalToConstant: 36).isActive = true
        searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        if let trackersLabel = trackersLabel {
            searchTextField.topAnchor.constraint(equalTo: trackersLabel.bottomAnchor, constant: 10).isActive = true
        }
        
        let attributes = [NSAttributedString.Key.foregroundColor : UIColor(named: "YPGray") ?? .gray]
        let attributePlacedHolder = NSAttributedString(string: "Поиск", attributes: attributes)
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
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.dataSource = self
        collectionView.delegate = self
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
        imageView.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Что будем отслеживать?"
        label.font = UIFont(name: "SF Pro Medium", size: 12)
        label.textAlignment = .center
        emptyView.addSubview(label)
        label.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
        self.emptyView = emptyView
    }
    
    private func changeEmptyStateForCollectionView(show: Bool) {
        emptyView?.isHidden = !show
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return trackerCategoryStore?.numberOfSections ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return trackerCategoryStore?.numbersOfObjectsInSection(section) ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }
        guard let tracker = try? trackerCategoryStore?.object(at: indexPath) else {
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
}

extension TrackersViewController: TrackerCategoryStoreDelegate {
    
    func didUpdate() {
        collectionView?.reloadData()
        let show = trackerCategoryStore?.numberOfItems() == 0
        changeEmptyStateForCollectionView(show: show)
    }
}
