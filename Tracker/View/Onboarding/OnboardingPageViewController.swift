//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by Nikolay on 17.01.2025.
//

import UIKit

class OnboardingPageViewController: UIPageViewController {
    
    // MARK: - IB Outlets
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = UIColor(named: "YPBlack")
        pageControl.pageIndicatorTintColor = UIColor(named: "YPGray")
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .red
        button.layer.cornerRadius = 16
        button.backgroundColor = UIColor(named: "YPBlack")
        let font = UIFont(name: "SF Pro Medium", size: 16) ?? UIFont.systemFont(ofSize: 16)
        let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : font,
                                                          NSAttributedString.Key.foregroundColor : UIColor.white]
        let attributedTitle = NSAttributedString(string: NSLocalizedString("Now that's technology!", comment: "Onboarding button title"), attributes: attributes)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Private Properties
    private let onboardingLaunchedKey = "onboardingLaunched"
    private var onboardingLaunched = false
    
    private lazy var pages: [OnboardingContentViewController] = {
        let first = OnboardingContentViewController()
        first.imageView.image = UIImage(named: "OnboardingImage1")
        first.label.text = NSLocalizedString("Track only what you want", comment: "Onboarding label 1")
        let second = OnboardingContentViewController()
        second.imageView.image = UIImage(named: "OnboardingImage2")
        second.label.text = NSLocalizedString("Even it is not liters of water and yoga", comment: "Onboarding label 2")
        return [first, second]
    }()

    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        view.backgroundColor = .white
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true)
        }
        setupLayout()
        onboardingLaunched = UserDefaults.standard.bool(forKey: onboardingLaunchedKey)
    }
    
    // MARK: - IB Actions
    @objc private func buttonTapped() {
        
        if onboardingLaunched {
            switchToTabbaraViewController()
        } else {
            UserDefaults.standard.set(true, forKey: onboardingLaunchedKey)
        }
        
        if let currentViewController = self.viewControllers?.first as? OnboardingContentViewController, let currentIndex = pages.firstIndex(of: currentViewController) {
            
            switch(currentIndex) {
            case 0:
                let secondViewController = pages[1]
                setViewControllers([secondViewController], direction: .forward, animated: true)
                pageViewController(self, didFinishAnimating: true, previousViewControllers: [], transitionCompleted: true)
            case 1:
                switchToTabbaraViewController()
            default:
                break
            }
        }
    }
    
    // MARK: - Private Methods
    private func setupLayout() {
        view.addSubview(pageControl)
        view.addSubview(button)
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -168),
            
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -84),
            button.heightAnchor.constraint(equalToConstant: 60),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func switchToTabbaraViewController() {
        
        guard let window = UIApplication.shared.windows.first else {
            return
        }
        
        window.rootViewController = TabBarController()
        window.makeKeyAndVisible()
    }
}

// MARK: - UIPageViewControllerDelegate
extension OnboardingPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if let currentViewController = pageViewController.viewControllers?.first as? OnboardingContentViewController,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            
            if currentIndex < pages.count {
                pageControl.currentPage = currentIndex
            } else {
                switchToTabbaraViewController()
            }
        } else {
            switchToTabbaraViewController()
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
        guard let currentViewController = self.viewControllers?.first as? OnboardingContentViewController, let _ = pages.firstIndex(of: currentViewController) else {
            
            switchToTabbaraViewController()
            return
        }
    }
}

// MARK: - UIPageViewControllerDataSource
extension OnboardingPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let onboardingViewController = viewController as? OnboardingContentViewController, let currentIndex = pages.firstIndex(of: onboardingViewController) else {
            return nil
        }

        let nextIndex = currentIndex + 1
        
        switch(nextIndex) {
        case 2:
            return TabBarController()
        case 1:
            return pages[nextIndex]
        default:
            break
        }
        
        return nil
    }
}

