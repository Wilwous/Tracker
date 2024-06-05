//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Антон Павлов on 04.06.2024.
//

import UIKit

final class OnboardingViewController: UIPageViewController {
    
    lazy var pageControl: UIPageControl = {
        let page = UIPageControl()
        page.currentPage = 0
        page.currentPageIndicatorTintColor = .ypGray
        page.currentPageIndicatorTintColor = .ypBlackDay
        page.numberOfPages = OnboardingPage.allCases.count
        
        return page
    }()
    
    lazy var continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Вот это технологии!", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.addTarget(
            self,
            action: #selector(continueButtonTapped),
            for: .touchUpInside
        )
        
        return button
    }()
    
    // MARK: - Initialization
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        
        addElements()
        layoutConstraint()
        
        if let firstPage = viewController(for: .pageOne) {
            setViewControllers([firstPage], direction: .forward, animated: true, completion: nil)
        }
    }
    
    // MARK: - Setup View
    private func addElements() {
        [pageControl,
         continueButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func layoutConstraint() {
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -24),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 20),
            
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            continueButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Navigation
    private func switchToMainInterface() {
        if let window = view?.window {
            let mainTabBarController = TabBarViewController()
            window.rootViewController = mainTabBarController
            UIView.transition(
                with: window,
                duration: 0.5,
                options: .transitionCrossDissolve,
                animations: nil,
                completion: nil
            )
        }
    }
    
    private func viewController(for page: OnboardingPage) -> UIViewController? {
        return OnboardingPageViewController(page: page)
    }
    
    // MARK: - Actions
    @objc private func continueButtonTapped() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        switchToMainInterface()
    }
}

// MARK: - UIPageViewControllerDataSource
extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let onboardingVC = viewController as? OnboardingPageViewController,
              let currentPage = OnboardingPage(rawValue: onboardingVC.page.rawValue - 1) else {
            return nil
        }
        return self.viewController(for: currentPage)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let onboardingVC = viewController as? OnboardingPageViewController,
              let currentPage = OnboardingPage(rawValue: onboardingVC.page.rawValue + 1) else {
            return nil
        }
        return self.viewController(for: currentPage)
    }
}

// MARK: - UIPageViewControllerDelegate
extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool
    ) {
        if completed,
           let visibleController = pageViewController.viewControllers?.first as? OnboardingPageViewController {
            pageControl.currentPage = visibleController.page.rawValue
        }
    }
}

