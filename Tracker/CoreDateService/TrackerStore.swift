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
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!
    
    // MARK: - Initialization
    init(managedObjectContext: NSManagedObjectContext = CoreDataStack.shared.persistentContainer.viewContext) {
        self.managedObjectContext = managedObjectContext
        super.init()
        setupFetchedResultsController()
    }
    
    // MARK: - Public Methods
    func createTracker(from tracker: Tracker, in category: TrackerCategoryCoreData) {
        let trackerCoreData = TrackerCoreData(context: managedObjectContext)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        //            trackerCoreData.color = tracker.color.toHexString()
        trackerCoreData.color = tracker.color.color.toHexString()
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.timetable = tracker.timetableToJSON()
        trackerCoreData.category = category
        
        print("🍔 Saving tracker with name: \(tracker.name), category: \(category.title ?? "Unknown")")
        
        saveContext()
    }
    
    func fetchAllTrackers() -> [Tracker] {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        do {
            let results = try managedObjectContext.fetch(fetchRequest)
            return results.compactMap { trackerCoreData in
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
        } catch {
            print("Failed to fetch trackers: \(error)")
            return []
        }
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
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
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
        print("🍔 controllerDidChangeContent called")
        delegate?.trackerStoreDidChange()
    }
}
