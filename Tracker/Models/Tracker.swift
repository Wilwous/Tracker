//
//  Tracker.swift
//  Tracker
//
//  Created by Антон Павлов on 04.02.2024.
//

import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let timetable: [WeekDay]
    let completedDays: [Date]
}
