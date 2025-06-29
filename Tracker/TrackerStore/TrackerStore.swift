import Foundation
import CoreData
import UIKit

protocol TrackerStoreDelegate: AnyObject {
    func storeDidUpdateTrackersStore(_ store: TrackerStore)
}

class TrackerStore: NSObject {
    
    weak var delegate: TrackerStoreDelegate?
    
    var context: NSManagedObjectContext!
    var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!
    
    init (context: NSManagedObjectContext) {
        self.context = context
    }
    convenience override init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        self.init(context: context)
    }
    func setupFetchedResultsController() {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("\(error)")
        }
    }
    func fetchTrackers(name: String) throws -> [TrackerCoreData] {
        guard let objects = fetchedResultsController.fetchedObjects else {
            return []
        }
        return objects
    }
    func addTracker(name: String) throws {
        let newTracker = TrackerCoreData(context: context)
        newTracker.name = name
        try context.save()
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeDidUpdateTrackersStore(self)
    }
}
