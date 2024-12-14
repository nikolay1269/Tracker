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
    private var searchBar: UISearchBar?
    private var searchController: UISearchController?
    private var collectionView: UICollectionView?
    private var emptyView: UIView?
    
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    
    private let cellIdentifier = "trackCellIdentifier"
    private let headerIdentifier = "headerIdentifier"

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addLeftNavigationBarItem()
        addTrackersLabel()
        addCollectionView()
        addEmptyView()
        addDateTimePicker()
        emptyView?.isHidden = true
        collectionView?.reloadData()
        generateTestData()
    }
    
    private func generateTestData() {
        let morningTrackers = [Tracker(id: "1", name: "Выпить стакан воды", color: .yellow, emoji: "😌", schedule: "Every day"),
                    Tracker(id: "2", name: "Зарядка", color: .red, emoji: "😙", schedule: "Every day")]
        let weeklyTrackers = [Tracker(id: "3", name: "Бассейн", color: .blue, emoji: "😍", schedule: "Weekly")]
        let morningCategory = TrackerCategory(name: "Утро", trackers: morningTrackers)
        let weeklyCategory = TrackerCategory(name: "Еженедельные", trackers: weeklyTrackers)
        categories = [morningCategory, weeklyCategory]
    }
    
    private func addLeftNavigationBarItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(plusButtonTap))
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    @objc private func plusButtonTap() {
        print("Plus button tapped")
    }
    
    private func addDateTimePicker() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        let currentDate = Date()
        let calendar = Calendar.current
        let minDate = calendar.date(byAdding: .year, value: -10, to: currentDate)
        let maxDate = calendar.date(byAdding: .year, value: 10, to: currentDate)
        datePicker.minimumDate = minDate
        datePicker.maximumDate = maxDate
        datePicker.addTarget(self, action: #selector(datePickerValueChange(_:)), for: .valueChanged)
    }
    
    @objc func datePickerValueChange(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let formattedDate = dateFormatter.string(from: selectedDate)
        print("Выбранная дата: \(formattedDate)")
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
    
    private func addSearchBar() {
        let viewForSearchBar = UIView(frame: CGRect(x: 0, y: 0, width: 343, height: 36))
        viewForSearchBar.translatesAutoresizingMaskIntoConstraints = false
        
        searchController = UISearchController()
        searchController?.searchBar.sizeToFit()
        let searchBar = searchController?.searchBar
        searchBar?.translatesAutoresizingMaskIntoConstraints = false
        if let searchBar = searchBar {
            view.addSubview(searchBar)
            searchBar.barStyle = .black
            searchBar.placeholder = "Поиск"
            searchBar.text = "Поиск"
            searchBar.layer.cornerRadius = 10
            searchBar.searchTextField.textColor = UIColor(named: "SearchPlaceHolderTextColor")
            searchBar.searchTextField.font = UIFont(name: "SF Pro Regular", size: 17)
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
            if let trackersLabel = trackersLabel {
                searchBar.topAnchor.constraint(equalTo: trackersLabel.bottomAnchor, constant: 7).isActive = true
            }
        }
        //self.searchBar = searchBar
    }

    private func addCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //layout.itemSize = CGSize(width: 167, height: 148)
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        if let trackersLabel = trackersLabel {
            collectionView.topAnchor.constraint(equalTo: trackersLabel.bottomAnchor, constant: 5).isActive = true
        }
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.dataSource = self
        collectionView.delegate = self
        self.collectionView = collectionView
    }
    
    private func addEmptyView() {
        
        guard let collectionView = collectionView else {
            return
        }
        
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

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let trackers = categories[section].trackers
        return trackers.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let trackers = categories[indexPath.section].trackers
        let tracker = trackers[indexPath.row]
        cell.configureCell(tracker: tracker)
        return cell
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
        
        return CGSize(width: collectionView.frame.width, height: 46)
    }
}
