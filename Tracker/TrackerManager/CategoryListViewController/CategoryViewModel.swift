//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Антон Павлов on 06.06.2024.
//

import Foundation

final class CategoryViewModel {
    
    // MARK: - Closures
    var onCategorySelected: ((String) -> Void)?
    var onViewStateUpdated: ((ViewState) -> Void)?
    
    // MARK: - Public Properties
    var selectedCategory: TrackerCategory?
    var selectedIndex: IndexPath?
    
    var categories: [TrackerCategory] = []{
        didSet {
            updateViewState()
        }
    }
    
    // MARK: - Private Properties
    private let categoryStore = CoreDataStack.shared.trackerCategoryStore
    
    private(set) var viewState: ViewState = .empty {
        didSet {
            onViewStateUpdated?(viewState)
        }
    }
    
    // MARK: - Initialization
    init() {
        loadCategories()
    }
    
    // MARK: - Public Methods
    func loadCategories() {
        updateViewState()
    }
    
    func selectCategory(at index: Int) {
        selectedCategory = categories[index]
        selectedIndex = IndexPath(row: index, section: 0)
    }
    
    private func updateViewState() {
        let state: ViewState = categories.isEmpty ? .empty : .populated
        onViewStateUpdated?(state)
    }
}
