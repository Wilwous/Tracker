//
//  DataSource.swift
//  Tracker
//
//  Created by Антон Павлов on 21.02.2024.
//

import UIKit

final class DataSource {
    
    static let shared = DataSource()
    
    // MARK: - Private Properties
    var trackerCategories: [TrackerCategory] = []
    
    // MARK: - Initializers
    private init() {
        self.trackerCategories = [
            TrackerCategory(headline: "Домашний уют", trackers: [
                Tracker(id: UUID(), name: "Поливать цветы", color: CodableColor(color: .colorSelection16), emoji: "🌺", timetable: [.monday, .wednesday, .friday], completedDays: []),
                Tracker(id: UUID(), name: "Налить стакан воды", color: CodableColor(color: .colorSelection6), emoji: "💧", timetable: [.friday, .saturday, .sunday], completedDays: [])
            ]),
            TrackerCategory(headline: "Уборка", trackers: [
                Tracker(id: UUID(), name: "Помыть посуду", color: CodableColor(color: .colorSelection12), emoji: "🍽", timetable: [.saturday], completedDays: []),
                Tracker(id: UUID(), name: "Помыть полы", color: CodableColor(color: .colorSelection14), emoji: "🧹", timetable: [.tuesday, .sunday], completedDays: [])
            ])
        ]
    }
    
    // MARK: - Public Methods
    func getTrackerCategories() -> [TrackerCategory] {
        return self.trackerCategories
    }
}
