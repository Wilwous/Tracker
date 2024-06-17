//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by Антон Павлов on 04.06.2024.
//

import UIKit

final class OnboardingPageViewController: UIViewController {
    
    // MARK: - Public Properties
    let page: OnboardingPage
    
    // MARK: - UI Components
    private lazy var backgroundImageView: UIImageView = {
        let view = UIImageView(
            image: UIImage(named: page.imageName)
        )
        view.contentMode = .scaleAspectFill
        
        return view
    }()
    
    private lazy var textLabel = {
        let text = UILabel()
        text.numberOfLines = 0
        text.font = .boldSystemFont(ofSize: 32)
        text.textAlignment = .center
        text.textColor = .black
        text.backgroundColor = .clear
        text.text = page.titlePage
        
        return text
    }()
    
    // MARK: - Initialization
    init(page: OnboardingPage) {
        self.page = page
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        addElements()
        layoutConstraint()
    }
    
    // MARK: - Setup View
    private func addElements() {
        [backgroundImageView,
         textLabel
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func layoutConstraint() {
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            textLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -270),
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}
