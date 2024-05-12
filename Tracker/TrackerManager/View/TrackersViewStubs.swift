//
//  TrackersViewStubs.swift
//  Tracker
//
//  Created by Антон Павлов on 20.04.2024.
//

import UIKit

final class TrackersViewStubs: UIView {
    
    // MARK: - Private Properties
    private lazy var willTrackLabel: UILabel = {
        let trackLabel = UILabel()
        trackLabel.text = "Что будем отслеживать?"
        trackLabel.font = .boldSystemFont(ofSize: 12)
        trackLabel.textColor = .ypBlackDay
        trackLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return trackLabel
    }()
    
    private lazy var imagesViewStub = {
        let imageView = UIImageView(image: UIImage(named: "error1"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        addElements()
        layoutConstraint()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup View
    private func addElements() {
        self.addSubview(willTrackLabel)
        self.addSubview(imagesViewStub)
    }
    
    private func layoutConstraint() {
        NSLayoutConstraint.activate([
            willTrackLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            willTrackLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            imagesViewStub.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            imagesViewStub.bottomAnchor.constraint(equalTo: willTrackLabel.topAnchor, constant: -8),
            imagesViewStub.heightAnchor.constraint(equalToConstant: 80),
            imagesViewStub.widthAnchor.constraint(equalToConstant: 80),
        ])
    }
}
