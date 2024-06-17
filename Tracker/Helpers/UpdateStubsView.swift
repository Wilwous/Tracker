//
//  UpdateEmptyState.swift
//  Tracker
//
//  Created by Антон Павлов on 17.06.2024.
//

import UIKit

enum UpdateStubsView {
    case noCategories
    case noTrackers
    case noResults
    case noStats
    
    var image: UIImage? {
        switch self {
        case .noCategories:
            return UIImage(named: "error1")
        case .noTrackers:
            return UIImage(named: "error1")
        case .noResults:
            return UIImage(named: "error2")
        case .noStats:
            return UIImage(named: "error3")
        }
    }
    
    var text: String {
        switch self {
        case .noCategories:
            return LocalizationHelper.localizedString("stubsCategory")
        case .noTrackers:
            return LocalizationHelper.localizedString("labelStub")
        case .noResults:
            return  LocalizationHelper.localizedString("nothing found")
        case .noStats:
            return LocalizationHelper.localizedString("emptyStatisticText")
        }
    }
}
