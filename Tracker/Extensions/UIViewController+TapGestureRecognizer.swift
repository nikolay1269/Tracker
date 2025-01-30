//
//  UIViewController+TapGestureRecognizer.swift
//  Tracker
//
//  Created by Nikolay on 30.01.2025.
//

import UIKit

extension UIViewController {
    func addTapGestureRegocnizerForHidingKeyboard() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
}
