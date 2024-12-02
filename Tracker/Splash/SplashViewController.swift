//
//  ViewController.swift
//  Tracker
//
//  Created by Nikolay on 26.11.2024.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 55.0 / 255.0, green: 114.0 / 255.0, blue: 231.0 / 255.0, alpha: 1.0)
        addLogoImage()
        sleep(3)
        swithToTrackersScreen()
    }
    
    private func addLogoImage() {
        let imageView = UIImageView(image: UIImage(named: "splash_logo"))
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 91).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 94).isActive = true
    }
    
    private func swithToTrackersScreen() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let window = appDelegate.window else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let trackersViewController = TrackersViewController()
        window.rootViewController = trackersViewController
        window.makeKeyAndVisible()
    }
}

