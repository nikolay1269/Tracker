//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Nikolay on 28.11.2024.
//

import UIKit

class TrackersViewController: UIViewController {
    
    private var plusButton: UIButton?
    private var dateTimeLabel: UILabel?
    private var trackersLabel: UILabel?
    private var searchBar: UISearchBar?
    private var searchController: UISearchController?
    private var collectionView: UICollectionView?
    private var emptyView: UIView?
    
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        //addPlusButton()
        //addDateTimeLabel()
        addLeftNavigationBarItem()
        addRightNavigationBarItem()
        addTrackersLabel()
        //addSearchBar()
        addCollectionView()
        addEmptyView()
    }
    
    private func addLeftNavigationBarItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(plusButtonTap))
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    @objc private func plusButtonTap() {
        print("Plus button tapped")
    }
    
    private func addRightNavigationBarItem() {
        
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 77, height: 34)
        let color = UIColor(red: 240.0 / 255.0, green: 240.0 / 255.0, blue: 240.0 / 255.0, alpha: 1.0)
        button.backgroundColor = color
        button.layer.cornerRadius = 10
        let font = UIFont(name: "SF Pro Regular", size: 17)
        let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font: font ?? UIFont.systemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: UIColor.black]
        let attributedString = NSAttributedString(string: Date().stringFromDateForTrackersScreen()!,
                                                  attributes: attributes)
        button.setAttributedTitle(attributedString, for: .normal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    @objc private func dateLabelTapped() {
        print("Date button tapped")
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
        layout.itemSize = CGSize(width: 167, height: 167)
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        if let trackersLabel = trackersLabel {
            collectionView.topAnchor.constraint(equalTo: trackersLabel.bottomAnchor, constant: 5).isActive = true
        }
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
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
    
//    private func addPlusButton() {
//        let plusButton = UIButton()
//        plusButton.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(plusButton)
//        plusButton.heightAnchor.constraint(equalToConstant: 42).isActive = true
//        plusButton.widthAnchor.constraint(equalToConstant: 42).isActive = true
//        plusButton.setImage(UIImage(named: "plus"), for: .normal)
//        plusButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6).isActive = true
//        plusButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 45).isActive = true
//        self.plusButton = plusButton
//    }
//
//    private func addDateTimeLabel() {
//        let containerViewForLabel = UIView()
//        containerViewForLabel.translatesAutoresizingMaskIntoConstraints = false
//        containerViewForLabel.backgroundColor = UIColor(named: "BackgroundLabelColor")
//        view.addSubview(containerViewForLabel)
//        let dateTimeLabel = UILabel()
//        dateTimeLabel.translatesAutoresizingMaskIntoConstraints = false
//        dateTimeLabel.text = Date().stringFromDateForTrackersScreen()
//        containerViewForLabel.addSubview(dateTimeLabel)
//        dateTimeLabel.backgroundColor = .clear
//        containerViewForLabel.layer.cornerRadius = 8
//        dateTimeLabel.font = UIFont(name: "SF Pro Regular", size: 17)
//        dateTimeLabel.textAlignment = .right
//        containerViewForLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
//        containerViewForLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5).isActive = true
//        dateTimeLabel.leadingAnchor.constraint(equalTo: containerViewForLabel.leadingAnchor, constant: 6).isActive = true
//        dateTimeLabel.trailingAnchor.constraint(equalTo: containerViewForLabel.trailingAnchor, constant: -6).isActive = true
//        dateTimeLabel.topAnchor.constraint(equalTo: containerViewForLabel.topAnchor, constant: 6).isActive = true
//        dateTimeLabel.bottomAnchor.constraint(equalTo: containerViewForLabel.bottomAnchor, constant: -6).isActive = true
//    }
//
//    private func addImageView() {
//
//        let imageView = UIImageView(image: UIImage(named: "TrackersEmptyScreen"))
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(imageView)
//        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        imageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
//        imageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
//    }
}
