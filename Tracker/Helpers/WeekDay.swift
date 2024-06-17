//
//  WeekDay.swift
//  Tracker
//
//  Created by Антон Павлов on 14.01.2024.
//

import Foundation

enum WeekDay: String, CaseIterable, Codable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    var numberValue: Int {
        switch self {
        case .monday:
            return 2
        case .tuesday:
            return 3
        case .wednesday:
            return 4
        case .thursday:
            return 5
        case .friday:
            return 6
        case .saturday:
            return 7
        case .sunday:
            return 1
        }
    }
    
    var shortTitle: String {
        switch self {
        case .monday:
            return LocalizationHelper.localizedString("mondayShort")
        case .tuesday:
            return LocalizationHelper.localizedString("tuesdayShort")
        case .wednesday:
            return LocalizationHelper.localizedString("wednesdayShort")
        case .thursday:
            return LocalizationHelper.localizedString("thursdayShort")
        case .friday:
            return LocalizationHelper.localizedString("fridayShort")
        case .saturday:
            return LocalizationHelper.localizedString("saturdayShort")
        case .sunday:
            return LocalizationHelper.localizedString("sundayShort")
        }
    }
    
    func asText() -> String {
        switch self {
        case .monday:
            return LocalizationHelper.localizedString("monday")
        case .tuesday:
            return LocalizationHelper.localizedString("tuesday")
        case .wednesday:
            return LocalizationHelper.localizedString("wednesday")
        case .thursday:
            return LocalizationHelper.localizedString("thursday")
        case .friday:
            return LocalizationHelper.localizedString("friday")
        case .saturday:
            return LocalizationHelper.localizedString("saturday")
        case .sunday:
            return LocalizationHelper.localizedString("sunday")
        }
    }
}

extension WeekDay {
    static func from(date: Date) -> WeekDay? {
        let calendar = Calendar.current
        let weekdayNumber = calendar.component(.weekday, from: date)
        return WeekDay.allCases.first { $0.numberValue == weekdayNumber }
    }
}
