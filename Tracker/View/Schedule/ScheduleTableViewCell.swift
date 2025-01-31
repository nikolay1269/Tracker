//
//  ScheduleTableViewCell.swift
//  Tracker
//
//  Created by Nikolay on 18.12.2024.
//

import UIKit

final class ScheduleTableViewCell: UITableViewCell {
    
    private let dayOfWeekSwitch = UISwitch()
    var dayOfWeekValueChanged: ((Bool) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor(named: "TextFieldBackgroundColor")
        addDayOfWeekSwitch()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dayOfWeekSwitch.isOn = false
    }
    
    func setCellSelected(_ selected: Bool) {
        dayOfWeekSwitch.isOn = selected
    }
    
    private func addDayOfWeekSwitch() {
        dayOfWeekSwitch.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dayOfWeekSwitch)
        dayOfWeekSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        dayOfWeekSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        dayOfWeekSwitch.onTintColor = UIColor(named: "YPBlue")
        dayOfWeekSwitch.addTarget(self, action: #selector(dayOfWeekSwitchValueChanged), for: .valueChanged)
    }
    
    @objc private func dayOfWeekSwitchValueChanged() {
        guard let dayOfWeekValueChanged = dayOfWeekValueChanged else { return }
        dayOfWeekValueChanged(dayOfWeekSwitch.isOn)
    }
}
