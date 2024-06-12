//
//  OnboardingPage.swift
//  Tracker
//
//  Created by Антон Павлов on 04.06.2024.
//

import Foundation

enum OnboardingPage: Int, CaseIterable {
    case pageOne = 0
    case pageTwo
    
    var titlePage: String {
        switch self {
        case .pageOne:
            return LocalizationHelper.localizedString(
                "onboardingText1"
            )
        case .pageTwo:
            return LocalizationHelper.localizedString(
                "onboardingText2"
            )
        }
    }
    
    var imageName: String {
        switch self {
        case .pageOne:
            return "onboarding1"
        case .pageTwo:
            return "onboarding2"
        }
    }
}
