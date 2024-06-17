//
//  TrackersViewStubs.swift
//  Tracker
//
//  Created by Антон Павлов on 20.04.2024.
//

import UIKit

final class TrackersViewStubs: UIView {
    
    // MARK: - UI Components
    private lazy var labelStub: UILabel = {
        let trackLabel = UILabel()
        trackLabel.text = LocalizationHelper.localizedString(
            "willTrackLabel"
        )
        trackLabel.font = .systemFont(ofSize: 12, weight: .medium)
        trackLabel.textColor = .ypBlack
        
        return trackLabel
    }()
    
    private lazy var imagesViewStub = {
        let imageView = UIImageView(image: UIImage(
            named: "error1")
        )
        imageView.contentMode = .scaleAspectFit
        
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
    
    func configure(with type: UpdateStubsView, labelHeight: CGFloat) {
        imagesViewStub.image = type.image
        labelStub.text = type.text
        
        NSLayoutConstraint.activate([
            labelStub.heightAnchor.constraint(equalToConstant: labelHeight)
        ])
    }
    
    // MARK: - Setup View
    private func addElements() {
        [labelStub,
         imagesViewStub
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }
    
    private func layoutConstraint() {
        NSLayoutConstraint.activate([
            labelStub.centerXAnchor.constraint(equalTo: centerXAnchor),
            labelStub.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            imagesViewStub.centerXAnchor.constraint(equalTo: centerXAnchor),
            imagesViewStub.bottomAnchor.constraint(equalTo: labelStub.topAnchor, constant: -8),
            imagesViewStub.heightAnchor.constraint(equalToConstant: 80),
            imagesViewStub.widthAnchor.constraint(equalToConstant: 80)
        ])
    }
}
