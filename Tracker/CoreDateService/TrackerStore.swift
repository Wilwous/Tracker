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
    func createTracker(from tracker: Tracker, categoryTitle: String) {
        let trackerCoreData = TrackerCoreData(context: managedObjectContext)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = tracker.color.color.toHexString()
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.timetable = tracker.timetableToJSON()
        
        let categoryStore = TrackerCategoryStore(managedObjectContext: managedObjectContext)
        var category = categoryStore.fetchCategoryByName(name: categoryTitle)
        if category == nil {
            category = categoryStore.createCategory(title: categoryTitle)
        }
        
        if let category = category {
            category.addToTrackers(trackerCoreData)
        }
        
        saveContext()
        delegate?.trackerStoreDidChange()
    }
    
    func fetchTrackerByID(id: UUID) -> TrackerCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        do {
            let results = try managedObjectContext.fetch(fetchRequest)
            return results.first
        } catch {
            print("Failed to fetch tracker by ID: \(error)")
            return nil
        }
    }
    
    func fetchTrackersGroupedByCategory() -> [TrackerCategory] {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        do {
            let categoryResults = try managedObjectContext.fetch(fetchRequest)
            return categoryResults.map { category in
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
                    return Tracker(id: id, name: name, color: color, emoji: emoji, timetable: timetable, completedDays: [])
                }
                return TrackerCategory(headline: category.title ?? "Без категории", trackers: trackerModels)
            }
        } catch {
            print("Failed to fetch categories: \(error)")
            return []
        }
    }
    
    // MARK: - Private Methods
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
