//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Антон Павлов on 26.05.2024.
//

import Foundation
import CoreData

// MARK: - Protocols

protocol TrackerRecordStoreDelegate: AnyObject {
    func trackerRecordStoreDidChange()
}

final class TrackerRecordStore: NSObject {
    
    // MARK: - Delegate
    weak var delegate: TrackerRecordStoreDelegate?
    
    // MARK: - Private Properties
    private let managedObjectContext: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    
    // MARK: - Initialization
    init(managedObjectContext: NSManagedObjectContext = CoreDataStack.shared.persistentContainer.viewContext) {
        self.managedObjectContext = managedObjectContext
        super.init()
        setupFetchedResultsController()
    }
    
    // MARK: - Public Methods
    func addTrackerRecord(for trackerCoreData: TrackerCoreData, date: Date) {
        let trackerRecordCoreData = TrackerRecordCoreData(context: managedObjectContext)
        trackerRecordCoreData.id = UUID()
        trackerRecordCoreData.date = date
        trackerRecordCoreData.tracker = trackerCoreData
        saveContext()
    }
    
    func deleteTrackerRecord(for trackerCoreData: TrackerCoreData, date: Date) {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "tracker == %@ AND date == %@", trackerCoreData, date as CVarArg)
        do {
            let results = try managedObjectContext.fetch(fetchRequest)
            for result in results {
                managedObjectContext.delete(result)
            }
            saveContext()
        } catch {
            print("Failed to delete tracker record: \(error)")
        }
    }
    
    func fetchAllCompletedTrackers() -> [TrackerRecord] {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        do {
            let results = try managedObjectContext.fetch(fetchRequest)
            return results.map { trackerRecordCoreData in
                return TrackerRecord(id: trackerRecordCoreData.tracker?.id ?? UUID(),
                                     date: trackerRecordCoreData.date ?? Date())
            }
        } catch {
            print("Failed to fetch completed trackers: \(error)")
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
extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerRecordStoreDidChange()
    }
}

