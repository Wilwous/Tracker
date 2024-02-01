//
//  ViewController.swift
//  Tracker
//
//  Created by Антон Павлов on 17.01.2024.
//

import UIKit

class TrackerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    

    private func trackerLabel() {
        let trakersLabel = UILabel()
        trakersLabel.translatesAutoresizingMaskIntoConstraints = false
        trakersLabel.text = "Трекер"
        trakersLabel.font = UIFont.boldSystemFont(ofSize: 34)
        trakersLabel.textColor = .black
        view.addSubview(trakersLabel)
        
        NSLayoutConstraint.activate([
            trakersLabel.heightAnchor.constraint(equalToConstant: 16)
        
        
        
        ])
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}

