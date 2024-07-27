//
//  CustomTextField.swift
//  Tracker
//
//  Created by Антон Павлов on 06.06.2024.
//

import UIKit

final class CustomTextField: UITextField {
    init(placeholder: String) {
        super.init(frame: .zero)
        self.placeholder = placeholder
        textAlignment = .left
        layer.masksToBounds = true
        layer.cornerRadius = 16
        backgroundColor = .ypBackgroundDay
        rightViewMode = .always
        translatesAutoresizingMaskIntoConstraints = false
        
        let leftIndent = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: frame.height))
        leftView = leftIndent
        leftViewMode = .always
        
        let rightIndent = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: frame.height))
        rightView = rightIndent
        rightViewMode = .always
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
