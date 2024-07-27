//
//  Tracker.swift
//  Tracker
//
//  Created by Антон Павлов on 04.02.2024.
//

import UIKit

struct Tracker: Codable {
    let id: UUID
    let name: String
    let color: CodableColor
    let emoji: String
    let timetable: [WeekDay]?
    let creationDate: Date
    let initialCategory: String?
    
    static func completedDaysFromJSON(_ json: String) -> [Date]? {
        let decoder = JSONDecoder()
        if let data = json.data(using: .utf8) {
            return try? decoder.decode([Date].self, from: data)
        }
        return nil
    }
    
    static func timetableFromJSON(_ json: String) -> [WeekDay]? {
        let decoder = JSONDecoder()
        if let data = json.data(using: .utf8) {
            return try? decoder.decode([WeekDay].self, from: data)
        }
        return nil
    }
    
    func timetableToJSON() -> String? {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(timetable) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    func completedDaysToJSON() -> String? {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(creationDate) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}
