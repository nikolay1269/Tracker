//
//  NewHabitViewController.swift
//  Tracker
//
//  Created by Nikolay on 16.12.2024.
//

import UIKit

enum TrackerParamsTableView: Int {
    case category
    case schedule
}

enum TrackerType: Int {
    case habit
    case event
}

enum TrackerParamsCollectionView: Int {
    case emoji
    case color
}

class CreateTrackerViewController: UIViewController {
    
    // MARK: - IB Outlets
    private let titleLabel = UILabel()
    private let nameTextField = UITextField()
    private let createButton = UIButton()
    private let cancelButton = UIButton()
    private let paramsTableView = UITableView()
    private let maxLengthLabel = UILabel()
    private var nameStackView = UIStackView()
    private var maxLabelHeightConstraint: NSLayoutConstraint?
    private var trackerParamsCollectionView: UICollectionView?
    
    // MARK: - Public Properties
    var dayOfWeekSelected: Set<WeekDay> = Set<WeekDay>()
    var trackerCreated: ((Tracker, TrackerCategory) -> Void)?
    var trackerType: TrackerType?
    var selectedTrackerCategory: TrackerCategory?
    
    // MARK: - Private Properties
    private let nameMaxLength = 38
    private let colorCellIdenfifier = "colorCellIdenfifier"
    private let emojiCellIdentifier = "emojiCellIdentifier"
    private let collectionHeaderIdentifier = "headerlIdentifier"
    private let colors = [UIColor(named: "#FD4C49"), UIColor(named: "#FF881E"),
                          UIColor(named: "#007BFA"), UIColor(named: "#6E44FE"),
                          UIColor(named: "#33CF69"), UIColor(named: "#E66DD4"),
                          UIColor(named: "#F9D4D4"), UIColor(named: "#34A7FE"),
                          UIColor(named: "#46E69D"), UIColor(named: "#35347C"),
                          UIColor(named: "#FF674D"), UIColor(named: "#FF99CC"),
                          UIColor(named: "#F6C48B"), UIColor(named: "#7994F5"),
                          UIColor(named: "#832CF1"), UIColor(named: "#AD56DA"),
                          UIColor(named: "#8D72E6"), UIColor(named: "#2FD058")]
    private let emojies = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    private var currentColor: UIColor?
    private var currentEmoji: String?
    private var lastSelectedEmojiIndexPath: IndexPath?
    private var lastSelectedColorIndexPath: IndexPath?
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addTitleLabel()
        addNameTextField()
        addMaxLengthLabel()
        addNameStackView()
        addCreateButton()
        addCancelButton()
        addParamsTalbeView()
        addParamsCollectionView()
    }
    
    // MARK: - Private Methods
    private func addParamsCollectionView() {
        let layout = UICollectionViewFlowLayout()
        trackerParamsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        trackerParamsCollectionView?.translatesAutoresizingMaskIntoConstraints = false
        guard let trackerParamsCollectionView = trackerParamsCollectionView else { return }
        view.addSubview(trackerParamsCollectionView)
        trackerParamsCollectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: colorCellIdenfifier)
        trackerParamsCollectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: collectionHeaderIdentifier)
        trackerParamsCollectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: emojiCellIdentifier)
        trackerParamsCollectionView.allowsMultipleSelection = true
        trackerParamsCollectionView.topAnchor.constraint(equalTo: paramsTableView.bottomAnchor, constant: 16).isActive = true
        trackerParamsCollectionView.bottomAnchor.constraint(equalTo: createButton.topAnchor, constant: -16).isActive = true
        trackerParamsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        trackerParamsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        self.trackerParamsCollectionView = trackerParamsCollectionView
        self.trackerParamsCollectionView?.dataSource = self
        self.trackerParamsCollectionView?.delegate = self
        self.trackerParamsCollectionView?.reloadData()
    }
    
    private func addTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 35).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        switch(trackerType) {
        case .habit:
            titleLabel.text = "Новая привычка"
        case .event:
            titleLabel.text = "Новое нерегулярное событие"
        case .none:
            break
        }
        titleLabel.font = UIFont(name: "SF Pro Medium", size: 16)
        titleLabel.textColor = UIColor(named: "YPBlack")
        titleLabel.textAlignment = .center
    }
    
    private func addMaxLengthLabel() {
        maxLengthLabel.translatesAutoresizingMaskIntoConstraints = false
        maxLabelHeightConstraint =  maxLengthLabel.heightAnchor.constraint(equalToConstant: 0)
        maxLabelHeightConstraint?.isActive = true
        maxLengthLabel.text = "Ограничение 38 символов"
        maxLengthLabel.textAlignment = .center
        maxLengthLabel.textColor = UIColor(named: "YPRed")
        maxLengthLabel.font = UIFont(name: "SF Pro Regular", size: 17)
    }
    
    private func addNameStackView() {
        nameStackView = UIStackView(arrangedSubviews: [nameTextField, maxLengthLabel])
        nameStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameStackView)
        nameStackView.spacing = 8
        nameStackView.distribution = .fillProportionally
        nameStackView.axis = .vertical
        nameStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24).isActive = true
        nameStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        nameStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        nameStackView.isUserInteractionEnabled = true
    }
    
    private func addNameTextField() {
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        nameStackView.addSubview(nameTextField)
        nameTextField.placeholder = "Введите название трекера"
        nameTextField.font = UIFont(name: "SF Pro Regular", size: 17)
        nameTextField.backgroundColor = UIColor(named: "TextFieldBackgroundColor")
        nameTextField.heightAnchor.constraint(equalToConstant: 75).isActive = true
        nameTextField.layer.cornerRadius = 16
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 75))
        paddingView.backgroundColor = .clear
        nameTextField.leftView = paddingView
        nameTextField.leftViewMode = .always
        nameTextField.clearButtonMode = .whileEditing
        nameTextField.addTarget(self, action: #selector(nameTextFieldEditingChanged), for: .editingChanged)
    }
    
    private func checkMaxLenght() {
        if let textLength = nameTextField.text?.count, textLength > nameMaxLength {
            maxLabelHeightConstraint?.constant = 30
        } else {
            maxLabelHeightConstraint?.constant = 0
        }
    }
    
    private func setCreateButtonEnabled() {
        if allRequiredFieldsNotEmpty() == true {
            createButton.backgroundColor = UIColor(named: "YPBlack")
            createButton.isEnabled = true
        } else {
            createButton.backgroundColor = UIColor(named: "YPGray")
            createButton.isEnabled = false
        }
    }
    
    private func allRequiredFieldsNotEmpty() -> Bool {
        guard let count = nameTextField.text?.count, count > 0 && count <= nameMaxLength &&
                (dayOfWeekSelected.count > 0 || trackerType == .event)
                && (currentColor != nil && currentEmoji != nil) && selectedTrackerCategory != nil else { return false }
        return true
    }
    
    private func addCreateButton() {
        createButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(createButton)
        let font = UIFont(name: "SF Pro Medium", size: 16) ?? UIFont.systemFont(ofSize: 17)
        let color = UIColor(named: "YPWhite") ?? UIColor.black
        let attributes = [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor : color]
        let attributedTitle = NSAttributedString(string: "Создать", attributes: attributes)
        createButton.setAttributedTitle(attributedTitle, for: .normal)
        createButton.layer.cornerRadius = 16
        createButton.backgroundColor = UIColor(named: "YPGray")
        createButton.isEnabled = false
        createButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        createButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34).isActive = true
        createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
    }
    
    private func createTracker() -> Tracker {
        
        return Tracker(id: UUID(),
                       name: nameTextField.text ?? "",
                       color: currentColor ?? .white,
                       emoji: currentEmoji ?? "",
                       schedule: dayOfWeekSelected)
    }
    
    private func addCancelButton() {
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cancelButton)
        let font = UIFont(name: "SF Pro Medium", size: 16) ?? UIFont.systemFont(ofSize: 17)
        let color = UIColor(named: "YPRed") ?? UIColor.black
        let attributes = [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor : color]
        let attributedTitle = NSAttributedString(string: "Отменить", attributes: attributes)
        cancelButton.setAttributedTitle(attributedTitle, for: .normal)
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.borderColor = UIColor(named: "YPRed")?.cgColor
        cancelButton.layer.borderWidth = 1
        cancelButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        cancelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34).isActive = true
        cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        cancelButton.trailingAnchor.constraint(equalTo: createButton.leadingAnchor, constant: -12).isActive = true
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cancelButton.widthAnchor.constraint(equalTo: createButton.widthAnchor).isActive = true
    }
    
    private func addParamsTalbeView() {
        paramsTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(paramsTableView)
        paramsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        paramsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        paramsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        paramsTableView.topAnchor.constraint(equalTo: nameStackView.bottomAnchor, constant: 24).isActive = true
        var tableHeight: CGFloat = 0
        switch (trackerType) {
        case .habit:
            tableHeight = 150
        case .event:
            tableHeight = 75
        case .none:
            tableHeight = 0
        }
        paramsTableView.heightAnchor.constraint(equalToConstant: tableHeight).isActive = true
        paramsTableView.dataSource = self
        paramsTableView.delegate = self
        paramsTableView.rowHeight = 75
        paramsTableView.layer.cornerRadius = 16
        paramsTableView.separatorStyle = .singleLine
        paramsTableView.separatorColor = UIColor(named: "YPGray")
        paramsTableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        paramsTableView.reloadData()
    }
    
    // MARK: - IB Actions
    @objc private func nameTextFieldEditingChanged() {
        checkMaxLenght()
        setCreateButtonEnabled()
    }
    
    @objc private func createButtonTapped() {
        guard let trackerCreated = trackerCreated, let selectedTrackerCategory = selectedTrackerCategory else { return }
        dismiss(animated: true)
        trackerCreated(createTracker(), selectedTrackerCategory)
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
}

//MARK: - UITableViewDataSource
extension CreateTrackerViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch(trackerType) {
        case .habit:
            return 2
        case .event:
            return 1
        case .none:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.selectionStyle = .none
        cell.textLabel?.font = UIFont(name: "SF Pro Regular", size: 17)
        cell.textLabel?.textColor = UIColor(named: "YPBlack")
        cell.detailTextLabel?.font = UIFont(name: "SF Pro Regular", size: 17)
        cell.detailTextLabel?.textColor = UIColor(named: "YPGray")
        cell.backgroundColor = UIColor(named: "TextFieldBackgroundColor")
        cell.accessoryType = .disclosureIndicator
        let lastIndex = trackerType == .habit ? 1 : 0
        if indexPath.row == lastIndex {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.size.width)
        }
        switch (indexPath.row) {
        case TrackerParamsTableView.category.rawValue:
            cell.textLabel?.text = "Категория"
            cell.detailTextLabel?.text = selectedTrackerCategory?.name
        case TrackerParamsTableView.schedule.rawValue:
            cell.textLabel?.text = "Расписание"
        default:
            break
        }
        return cell
    }
}

//MARK: - UITableViewDelegate
extension CreateTrackerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch(indexPath.row) {
        case TrackerParamsTableView.category.rawValue:
            let trackerCategoriesViewController = TrackerCategoriesViewController()
            let viewModel = TrackerCategoriesViewModel()
            trackerCategoriesViewController.viewModel = viewModel
            trackerCategoriesViewController.viewModel?.onTrackerCategorySelected = { [weak self] trackerCategoryViewModel in
                guard let self = self,
                      let id = trackerCategoryViewModel?.id,
                      let name = trackerCategoryViewModel?.name,
                      let trackers = trackerCategoryViewModel?.trackers else { return }
                
                let category = TrackerCategory(id: id,
                                               name: name,
                                               trackers: trackers)
                self.selectedTrackerCategory = category
                let cell = tableView.cellForRow(at: indexPath)
                cell?.detailTextLabel?.text = self.selectedTrackerCategory?.name
                self.setCreateButtonEnabled()
            }
            self.present(trackerCategoriesViewController, animated: true)
        case TrackerParamsTableView.schedule.rawValue:
            let scheduleViewController = ScheduleViewController()
            scheduleViewController.scheduleSelected = { [weak self] dayOfWeekSelected in
                guard let self = self else { return }
                var scheduleInfo: String = ""
                for dayOfWeek in dayOfWeekSelected.sorted(by: { weekday1, weekday2 in
                    (weekday1.rawValue < weekday2.rawValue || weekday2 == .sunday) && !(weekday1 == .sunday)
                }) {
                    var shortDayOfWeek = ""
                    switch(dayOfWeek) {
                    case .monday:
                        shortDayOfWeek = "Пн"
                    case .tuesday:
                        shortDayOfWeek = "Вт"
                    case .wednesday:
                        shortDayOfWeek = "Ср"
                    case .thursday:
                        shortDayOfWeek = "Чт"
                    case .friday:
                        shortDayOfWeek = "Пт"
                    case .saturday:
                        shortDayOfWeek = "Сб"
                    case .sunday:
                        shortDayOfWeek = "Вс"
                    }
                    scheduleInfo.append("\(shortDayOfWeek), ")
                }
                if scheduleInfo.count > 1 {
                    scheduleInfo.removeLast(2)
                }
                self.dayOfWeekSelected = dayOfWeekSelected
                guard let cell = tableView.cellForRow(at: IndexPath(row: TrackerParamsTableView.schedule.rawValue, section: 0)) else { return }
                cell.detailTextLabel?.text = scheduleInfo
                self.setCreateButtonEnabled()
            }
            self.present(scheduleViewController, animated: true)
        default:
            break
        }
    }
}

//MARK: - UICollectionViewDataSource
extension CreateTrackerViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let currentParam = TrackerParamsCollectionView(rawValue: section)
        switch(currentParam) {
        case .color:
            return colors.count
        case .emoji:
            return emojies.count
        case .none:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: collectionHeaderIdentifier, for: indexPath) as? SupplementaryView else { return UICollectionReusableView() }
        let currentParam = TrackerParamsCollectionView(rawValue: indexPath.section)
        switch(currentParam) {
        case .emoji:
            headerView.titleLabel.text = "Emoji"
        case .color:
            headerView.titleLabel.text = "Цвет"
        case .none:
            break
        }
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let currentParam = TrackerParamsCollectionView(rawValue: indexPath.section)
        switch(currentParam) {
        case .color:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: colorCellIdenfifier, for: indexPath) as? ColorCollectionViewCell,
                    let color = colors[indexPath.row] else { return UICollectionViewCell() }
            cell.configureCell(color: color)
            return cell
        case .emoji:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emojiCellIdentifier, for: indexPath) as? EmojiCollectionViewCell else { return
                UICollectionViewCell()
            }
            cell.configureCell(emoji: emojies[indexPath.row])
            return cell
        case .none:
            let cell = UICollectionViewCell()
            return cell
        }
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension CreateTrackerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: 34)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let currentParam = TrackerParamsCollectionView(rawValue: indexPath.section)
        switch(currentParam) {
        case .emoji:
            if let lastIndexPath = lastSelectedEmojiIndexPath, lastIndexPath != indexPath {
                guard let lastSelectedCell = collectionView.cellForItem(at: lastIndexPath) as? EmojiCollectionViewCell else { return }
                collectionView.deselectItem(at: lastIndexPath, animated: true)
                lastSelectedCell.setSelectedStatus(selected: false)
            }
            currentEmoji = emojies[indexPath.row]
            let cell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell
            cell?.setSelectedStatus(selected: true)
            lastSelectedEmojiIndexPath = indexPath
        case .color:
            if let lastIndexPath = lastSelectedColorIndexPath, lastIndexPath != indexPath {
                guard let lastSelectedCell = collectionView.cellForItem(at: lastIndexPath) as? ColorCollectionViewCell else { return }
                collectionView.deselectItem(at: lastIndexPath, animated: true)
                lastSelectedCell.setSelectedStatus(selected: false)
            }
            currentColor = colors[indexPath.row]
            let cell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell
            cell?.setSelectedStatus(selected: true)
            lastSelectedColorIndexPath = indexPath
        case .none:
            break
        }
        setCreateButtonEnabled()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let currentParam = TrackerParamsCollectionView(rawValue: indexPath.section)
        switch(currentParam) {
        case .emoji:
            let cell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell
            cell?.setSelectedStatus(selected: false)
        case .color:
            let cell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell
            cell?.setSelectedStatus(selected: false)
        case .none:
            break
        }
    }
}
