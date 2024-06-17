//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Антон Павлов on 26.05.2024.
//

import Foundation
import CoreData

// MARK: - Protocols

protocol TrackerCategoryStoreDelegate: AnyObject {
    func trackerCategoryStoreDidChange()
}

final class TrackerCategoryStore: NSObject {
    
    // MARK: - Delegate
    weak var delegate: TrackerCategoryStoreDelegate?
    
    // MARK: - Private Properties
    private let managedObjectContext: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?
    
    // MARK: - Initialization
    init(managedObjectContext: NSManagedObjectContext = CoreDataStack.shared.persistentContainer.viewContext) {
        self.managedObjectContext = managedObjectContext
        super.init()
        setupFetchedResultsController()
    }
    
    // MARK: - Public Methods
    func createCategory(title: String) {
        if fetchCategory(by: title) == nil {
            let category = TrackerCategoryCoreData(context: managedObjectContext)
            category.title = title
            saveContext()
        }
    }
    
    func fetchCategory(by title: String) -> TrackerCategoryCoreData? {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        return try? managedObjectContext.fetch(request).first
    }
    
    func fetchAllCategories() -> [TrackerCategory] {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        do {
            let results = try managedObjectContext.fetch(fetchRequest)
            return results.map { TrackerCategory(headline: $0.title ?? "По умолчанию", trackers: []) }
        } catch {
            print("Failed to fetch categories: \(error)")
            return []
        }
    }
    
    // MARK: - Private Methods
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
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
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerCategoryStoreDidChange()
    }
}

