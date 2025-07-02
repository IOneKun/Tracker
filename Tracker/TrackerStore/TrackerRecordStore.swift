import UIKit
import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func storeDidUpdateTrackerRecords(_ store: TrackerRecordStore)
}

final class TrackerRecordStore: NSObject {
    
    weak var delegate: TrackerRecordStoreDelegate?
    
    var context: NSManagedObjectContext!
    var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>?
    
    init (context: NSManagedObjectContext) {
        self.context = context
    }
    convenience override init() {
        let context = CoreDataManager.shared.context
        self.init(context: context)
    }
    func setupFetchedResultsController() {
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        let sortDescriptor = NSSortDescriptor(key: "trackerID", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("\(error)")
        }
    }
    func fetchTrackerRecords() throws -> [TrackerRecordCoreData] {
        guard let objects = fetchedResultsController?.fetchedObjects else {
            return []
        }
        return objects
    }
    func addTrackerRecord(with id: UUID, on date: Date) throws {
        let newTrackerRecord = TrackerRecordCoreData(context: context)
        newTrackerRecord.trackerID = id
        newTrackerRecord.date = date
        try context.save()
    }
    func isTrackerCompleted(_ trackerID: UUID, on date: Date) -> Bool {
        guard let records = fetchedResultsController?.fetchedObjects else { return false }
        return records.contains { (record: TrackerRecordCoreData) in
            guard let recordDate = record.date else { return false }
            return record.trackerID == trackerID && Calendar.current.isDate(recordDate, inSameDayAs: date)
        }
    }
    
    func completedDaysCount(for trackerID: UUID) -> Int {
        guard let records = fetchedResultsController?.fetchedObjects else { return 0 }
        return records.filter { $0.trackerID == trackerID }.count
    }
    func removeRecord(for trackerID: UUID, on date: Date) {
        guard let records = fetchedResultsController?.fetchedObjects else { return }
        
        if let recordToDelete = records.first(where: { (record: TrackerRecordCoreData) in
            guard let recordDate = record.date else { return false }
            return record.trackerID == trackerID && Calendar.current.isDate(recordDate, inSameDayAs: date)
        }) {
            context.delete(recordToDelete)
            do {
                try context.save()
            } catch {
                print("Ошибка при удалении записи трекера: \(error)")
            }
        }
    }
}
extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeDidUpdateTrackerRecords(self)
    }
}
