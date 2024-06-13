//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Антон Павлов on 13.06.2024.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    func testTrackersViewControllerLightMode() {
        let vc = TrackerViewController()
        assertSnapshot(
            matching: vc,
            as: .image(traits: .init(userInterfaceStyle: .light))
        )
    }
    
    func testTrackersViewControllerDarkMode() {
        let vc = TrackerViewController()
        assertSnapshot(
            matching: vc,
            as: .image(traits: .init(userInterfaceStyle: .dark))
        )
    }
}
