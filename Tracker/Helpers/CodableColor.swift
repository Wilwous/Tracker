//
//  CodableColor.swift
//  Tracker
//
//  Created by Антон Павлов on 28.05.2024.
//

import UIKit

struct CodableColor: Codable {
    
    let color: UIColor
    
    init(color: UIColor) {
        self.color = color
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let hexString = try container.decode(String.self)
        self.color = UIColor(hexString: hexString)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(color.toHexString())
    }
    
    func getUIColor() -> UIColor {
        return self.color
    }
}
