//
//  TrackerStore.swift
//  Tracker
//
//  Created by Антон Павлов on 26.05.2024.
//

import UIKit
import CoreData

// MARK: - Protocols
protocol TrackerStoreDelegate: AnyObject {
    func trackerStoreDidChange()
    func trackerStoreDidAddTracker(_ tracker: TrackerCoreData)
}

final class TrackerStore: NSObject {
    
    // MARK: - Delegate
    weak var delegate: TrackerStoreDelegate?
    
    // MARK: - Private Properties
    private let managedObjectContext: NSManagedObjectContext
    var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    
    // MARK: - Initialization
    init(managedObjectContext: NSManagedObjectContext = CoreDataStack.shared.persistentContainer.viewContext) {
        self.managedObjectContext = managedObjectContext
        super.init()
        setupFetchedResultsController()
    }
    
    // MARK: - Public Methods
    func fetchTracker(by: UUID) -> TrackerCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", by as CVarArg)
        do {
            let results = try managedObjectContext.fetch(fetchRequest)
            return results.first
        } catch {
            print("Failed to fetch tracker by ID: \(error)")
            return nil
        }
    }
    
    func createTracker(from tracker: Tracker, categoryTitle: String) {
        let trackerCoreData = TrackerCoreData(context: managedObjectContext)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = tracker.color.color.toHexString()
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.timetable = tracker.timetableToJSON()
        
        let categoryStore = TrackerCategoryStore(managedObjectContext: managedObjectContext)
        var category = categoryStore.fetchCategory(by: categoryTitle)
        if category == nil {
            categoryStore.createCategory(title: categoryTitle)
            category = categoryStore.fetchCategory(by: categoryTitle)
        }
        
        if let category = category {
            category.addToTrackers(trackerCoreData)
        }
        
        saveContext()
        delegate?.trackerStoreDidChange()
    }
    
    func updateTracker(
        trackerId: UUID,
        newName: String?,
        newColor: UIColor?,
        newEmoji: String?,
        newTimetable: [WeekDay]?,
        newCategory: String?
    ) {
        guard let trackerCoreData = fetchTracker(by: trackerId) else { return }
        
        if let newName = newName {
            trackerCoreData.name = newName
        }
        
        if let newColor = newColor {
            trackerCoreData.color = newColor.toHexString()
        }
        
        if let newEmoji = newEmoji {
            trackerCoreData.emoji = newEmoji
        }
        
        if let newTimetable = newTimetable {
            let timetableJSON = Tracker(
                id: trackerCoreData.id!,
                name: trackerCoreData.name!,
                color: CodableColor(color: UIColor(hexString: trackerCoreData.color!)),
                emoji: trackerCoreData.emoji!,
                timetable: newTimetable,
                creationDate: Date(),
                initialCategory: trackerCoreData.initialCategory).timetableToJSON()
            trackerCoreData.timetable = timetableJSON
        }
        
        if let newCategory = newCategory {
            let categoryStore = TrackerCategoryStore(managedObjectContext: managedObjectContext)
            var category = categoryStore.fetchCategory(by: newCategory)
            if category == nil {
                categoryStore.createCategory(title: newCategory)
                category = categoryStore.fetchCategory(by: newCategory)
            }
            
            if let category = category {
                trackerCoreData.category = category
                trackerCoreData.initialCategory = newCategory
            }
        }
        
        saveContext()
        delegate?.trackerStoreDidChange()
    }
    
    func convertToCoreData(
        tracker: Tracker) -> TrackerCoreData? {
            return fetchTracker(by: tracker.id)
        }
    
    func fetchCategoryEditing(for tracker: TrackerCoreData) -> String? {
        return tracker.category?.title
    }
    
    func fetchTrackersGroupedByCategory() -> [TrackerCategory] {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        do {
            let categoryResults = try managedObjectContext.fetch(fetchRequest)
            return categoryResults.compactMap { category in
                let trackers = (category.trackers?.allObjects as? [TrackerCoreData]) ?? []
                let trackerModels: [Tracker] = trackers.compactMap { trackerCoreData in
                    guard let id = trackerCoreData.id,
                          let name = trackerCoreData.name,
                          let colorHex = trackerCoreData.color,
                          let emoji = trackerCoreData.emoji,
                          let timetableJSON = trackerCoreData.timetable else {
                        return nil
                    }
                    let timetable = Tracker.timetableFromJSON(timetableJSON) ?? []
                    let color = CodableColor(color: UIColor(hexString: colorHex))
                    return Tracker(
                        id: id, name: name, color: color,
                        emoji: emoji, timetable: timetable,
                        creationDate: Date(),
                        initialCategory: nil
                    )
                }
                return trackerModels.isEmpty ? nil : TrackerCategory(
                    headline: category.title ?? "Без категории", trackers: trackerModels
                )
            }
        } catch {
            print("Failed to fetch categories: \(error)")
            return []
        }
    }
    
    // MARK: - ContextMenu
    func pinTracker(_ trackerId: UUID) {
        guard let trackerCoreData = fetchTracker(by: trackerId) else { return }
        
        if let currentCategory = trackerCoreData.category {
            currentCategory.removeFromTrackers(trackerCoreData)
            trackerCoreData.initialCategory = currentCategory.title
        }
        
        let pinnedCategory = createCategoryIfNotExists(with: "Закрепленные")
        trackerCoreData.category = pinnedCategory
        pinnedCategory.addToTrackers(trackerCoreData)
        
        saveContext()
    }
    
    func unpinTracker(_ trackerId: UUID) {
        guard let trackerCoreData = fetchTracker(by: trackerId) else { return }
        
        if let pinnedCategory = trackerCoreData.category, pinnedCategory.title == "Закрепленные" {
            pinnedCategory.removeFromTrackers(trackerCoreData)
        }
        
        if let originalCategoryTitle = trackerCoreData.initialCategory {
            if let originalCategory = fetchCategory(by: originalCategoryTitle) {
                trackerCoreData.category = originalCategory
                originalCategory.addToTrackers(trackerCoreData)
                trackerCoreData.initialCategory = nil
            } else {
                let newCategory = createCategoryIfNotExists(with: originalCategoryTitle)
                trackerCoreData.category = newCategory
                newCategory.addToTrackers(trackerCoreData)
                trackerCoreData.initialCategory = nil
            }
        }
        saveContext()
    }
    
    func deleteTracker(trackerId: UUID) {
        if let trackerCoreData = fetchTracker(by: trackerId) {
            CoreDataStack.shared.trackerRecordStore.deleteRecordsForTracker(with: trackerId)
            managedObjectContext.delete(trackerCoreData)
            saveContext()
        }
    }
    
    // MARK: - Private Methods
    private func createCategoryIfNotExists(with title: String) -> TrackerCategoryCoreData {
        if let existingCategory = fetchCategory(by: title) {
            return existingCategory
        } else {
            let newCategory = TrackerCategoryCoreData(context: managedObjectContext)
            newCategory.title = title
            saveContext()
            return newCategory
        }
    }
    
    private func fetchCategory(by title: String) -> TrackerCategoryCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        
        do {
            let results = try managedObjectContext.fetch(fetchRequest)
            return results.first
        } catch {
            print("Failed to fetch category: \(error)")
            return nil
        }
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Failed to fetch trackers: \(error)")
        }
    }
    
    private func saveContext() {
        let context = CoreDataStack.shared.persistentContainer.viewContext
        if context.hasChanges {
            context.registeredObjects.forEach { managedObject in
                if managedObject.hasChanges {
                    print("Изменённый объект: \(managedObject.entity.name ?? "Unknown Entity"), Статус: \(managedObject.changedValues())")
                }
            }
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("Failed to save context \(nserror), \(nserror.userInfo)")
            }
        } else {
            print("No context to save")
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerStoreDidChange()
    }
}
