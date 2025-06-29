import Foundation
import UIKit
import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func storeDidUpdateTrackerRecords(_ store: TrackerRecordStore)
}

class TrackerRecordStore: NSObject {
    
    weak var delegate: TrackerRecordStoreDelegate?
    
    var context: NSManagedObjectContext!
    var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>!
    
    init (context: NSManagedObjectContext) {
        self.context = context
    }
    convenience override init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        self.init(context: context)
    }
    func setupFetchedResultsController() {
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackkerRecordCoreData")
        let sortDescriptor = NSSortDescriptor(key: "trackerID", ascending: true)
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
    func fetchTrackerRecords() throws -> [TrackerRecordCoreData] {
        guard let objects = fetchedResultsController.fetchedObjects else {
            return []
        }
        return objects
    }
    func addTrackerRecord(with id: UUID) throws {
        let newTrackerRecord = TrackerRecordCoreData(context: context)
        newTrackerRecord.trackerID = id
        try context.save()
    }
}
extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeDidUpdateTrackerRecords(self)
    }
}
