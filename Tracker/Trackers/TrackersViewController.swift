//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Nikolay on 28.11.2024.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    private var plusButton: UIButton?
    private var dateTimeLabel: UILabel?
    private var trackersLabel: UILabel?
    private var collectionView: UICollectionView?
    private var emptyView: UIView?
    private var searchTextField: UISearchTextField?
    
    var categories: [TrackerCategory] = []
    var filteredCategories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    var competedTrackersUUIDs = Set<UUID>()
    
    private let cellIdentifier = "trackCellIdentifier"
    private let headerIdentifier = "headerIdentifier"
    
    private var currentDate: Date = Date()

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
        filterCategoriesByDateAndSearchText()
        collectionView?.reloadData()
    }
    
    private func generateTestData() {
        categories = [TrackerCategory(name: "Важное", trackers: [])]
    }
    
    private func addLeftNavigationBarItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(plusButtonTapped))
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    @objc private func plusButtonTapped() {
        let selectTrackerTypeViewController = SelectTrackerTypeViewController()
        selectTrackerTypeViewController.trackerCreated = { [weak self] newTracker in
            
            guard let self = self else { return }
            self.addNewTracker(tracker: newTracker)
            self.filterCategoriesByDateAndSearchText()
            self.collectionView?.reloadData()
        }
        self.present(selectTrackerTypeViewController, animated: true)
    }
    
    private func addNewTracker(tracker: Tracker) {
        let oldCategory = categories.first
        var newTrackers = oldCategory?.trackers
        newTrackers?.append(tracker)
        guard let newTrackers = newTrackers, let oldCategory = oldCategory else { return }
        let newCategory = TrackerCategory(name: oldCategory.name, trackers: newTrackers)
        categories = [newCategory]
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
    
    @objc func datePickerValueChange(_ sender: UIDatePicker) {
        currentDate = sender.date
        filterCategoriesByDateAndSearchText()
        collectionView?.reloadData()
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
    
    @objc private func searchTextFieldValueChanged() {
        filterCategoriesByDateAndSearchText()
        collectionView?.reloadData()
    }

    private func addCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
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
    
    private func filterCategoriesByDateAndSearchText() {
        
        guard let currentDayOfWeekInt = Calendar.current.dateComponents([.weekday], from: currentDate).weekday, let currentDayOfWeek = WeekDay(rawValue: currentDayOfWeekInt) else { return }
        let filteredText = searchTextField?.text?.lowercased() ?? ""
        filteredCategories = []
        for category in categories {
            var filteredTrackers: [Tracker] = []
            for tracker in category.trackers {
                if (trackerIsHabitAndCurrentDateInSchedule(tracker: tracker, currentDayOfWeek: currentDayOfWeek) ||
                    trackerIsEventAndNotCompletedOrCompletedInCurrentDate(tracker: tracker)) && (tracker.name.lowercased().contains(filteredText) || filteredText.isEmpty) {
                    
                    filteredTrackers.append(tracker)
                }
            }
            if !filteredTrackers.isEmpty {
                let newCategory = TrackerCategory(name: category.name, trackers: filteredTrackers)
                filteredCategories.append(newCategory)
            }
        }
         
        changeEmptyStateForCollectionView(show: filteredCategories.isEmpty)
    }
    
    private func trackerIsHabitAndCurrentDateInSchedule(tracker: Tracker, currentDayOfWeek: WeekDay) -> Bool {
        return tracker.schedule.contains(currentDayOfWeek)
    }
    
    private func trackerIsEventAndNotCompletedOrCompletedInCurrentDate(tracker: Tracker) -> Bool {
        let trackerIsEvent = tracker.schedule.count == 0
        let trackerIsNotCompleted = !competedTrackersUUIDs.contains(tracker.id)
        let completedDate = completedTrackers.filter { $0.id == tracker.id }.first?.date
        return trackerIsEvent && (trackerIsNotCompleted || completedDate?.scheduleComparison(date: currentDate) == .orderedSame)
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let trackers = filteredCategories[section].trackers
        return trackers.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }
        let trackers = filteredCategories[indexPath.section].trackers
        let tracker = trackers[indexPath.row]
        updateCellStatusAndDayCount(cell: cell, tracker: tracker)
        cell.trackerStatusChanged = { [weak self] in
            guard let self = self else { return }
            if self.isTrackerComplete(tracker: tracker) {
                for (index, competedTracker) in self.completedTrackers.enumerated() {
                    if competedTracker.id == tracker.id && competedTracker.date.scheduleComparison(date: self.currentDate) == .orderedSame {
                        self.completedTrackers.remove(at: index)
                        self.competedTrackersUUIDs.remove(tracker.id)
                        break
                    }
                }
            } else {
                let trackerRecord = TrackerRecord(id: tracker.id, date: self.currentDate)
                self.completedTrackers.append(trackerRecord)
                self.competedTrackersUUIDs.insert(tracker.id)
            }
            self.updateCellStatusAndDayCount(cell: cell, tracker: tracker)
        }
        return cell
    }
    
    private func isTrackerComplete(tracker: Tracker) -> Bool {
        return completedTrackers.filter { $0.id == tracker.id && $0.date.scheduleComparison(date: currentDate) == .orderedSame }.count > 0
    }
    
    private func updateCellStatusAndDayCount(cell: TrackerCollectionViewCell, tracker: Tracker) {
        let status = completedTrackers.filter { $0.id == tracker.id && $0.date.scheduleComparison(date: currentDate) == .orderedSame }.count > 0
        let daysCount = completedTrackers.filter { $0.id == tracker.id }.count
        cell.configureCell(tracker: tracker, status: status, daysCount: daysCount)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier, for: indexPath) as? SupplementaryView else { return UICollectionReusableView() }
        view.titleLabel.text = categories[indexPath.section].name
        return view
    }
}

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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}
