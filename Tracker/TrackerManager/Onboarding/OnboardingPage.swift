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
            return "Отслеживайте только то, что хотите"
        case .pageTwo:
            return "Даже если это не литры воды и йога"
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
