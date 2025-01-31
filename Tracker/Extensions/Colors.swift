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
        traits.userInterfaceStyle == .light ? UIColor.black : UIColor.white
    }
    
    let backgroundColor = UIColor { (traits: UITraitCollection) -> UIColor in
        traits.userInterfaceStyle == .light ? UIColor(named: "YPWhite") ?? .white : UIColor(named: "YPBlack") ?? .black
    }
    
    let tabBarTopBorderColor = UIColor { (traits: UITraitCollection) -> UIColor in
        traits.userInterfaceStyle == .light ? UIColor(named: "YPGray") ?? .gray : .black
    }
    
    let datePickerBackgroundColor = UIColor { (traits: UITraitCollection) -> UIColor in
        traits.userInterfaceStyle == .light ? UIColor(named: "DatePickerColor") ?? .gray : UIColor(named: "DatePickerColor") ?? .gray
    }
}
