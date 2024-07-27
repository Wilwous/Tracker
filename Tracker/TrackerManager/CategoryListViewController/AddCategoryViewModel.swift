//
//  AddCategoryViewModel.swift
//  Tracker
//
//  Created by Антон Павлов on 08.06.2024.
//

import Foundation

final class AddCategoryViewModel {
    
    // MARK: - Closures
    var onCategoryCreation: ((String) -> Void)?
    var onCreationButtonStateUpdated: ((Bool) -> Void)?

    // MARK: - Properties
    private let categoryStore = CoreDataStack.shared.trackerCategoryStore

    // MARK: - Public Methods
    func addCategory(name: String) {
        let category = categoryStore.createCategory(title: name)
        onCategoryCreation?(category.title ?? "")
    }

    func validateCategoryName(_ name: String?) {
        let isNameEntered = !(name?.isEmpty ?? true)
        onCreationButtonStateUpdated?(isNameEntered)
    }
}
