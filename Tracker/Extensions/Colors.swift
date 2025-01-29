//
//  Colors.swift
//  Tracker
//
//  Created by Nikolay on 29.01.2025.
//

import UIKit

final class Colors {
    
    static let shared = Colors()
    
    let leftNavigationBarButtonItemColor = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return UIColor.black
        } else {
            return UIColor.white
        }
    }
    
    let backgroundColor = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return UIColor(named: "YPWhite") ?? .white
        } else {
            return UIColor(named: "YPBlack") ?? .black
        }
    }
    
    let tabBarTopBorderColor = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return UIColor(named: "YPGray") ?? .gray
        } else {
            return .black
        }
    }
    
    let datePickerBackgroundColor = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return UIColor(named: "DatePickerColor") ?? .gray
        } else {
            return UIColor(named: "DatePickerColor") ?? .gray
        }
    }
}
