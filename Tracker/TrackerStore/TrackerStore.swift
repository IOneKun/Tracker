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
    func fetchTrackers() throws -> [TrackerCoreData] {
        guard let objects = fetchedResultsController.fetchedObjects else {
            return []
        }
        return objects
    }
    func addTracker(id: UUID, name: String, emoji: String, color: UIColor, schedule: [Weekday], category: String) throws {
        let categoryFetch: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        categoryFetch.predicate = NSPredicate(format: "name == %@", category)
        
        let categoryCoreData: TrackerCategoryCoreData
        
        if let existingCategory = try context.fetch(categoryFetch).first {
            categoryCoreData = existingCategory
        } else {
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.name = category
            categoryCoreData = newCategory
        }
        let newTracker = TrackerCoreData(context: context)
        newTracker.id = id
        newTracker.name = name
        newTracker.emoji = emoji
        newTracker.color = color.toHexString
        newTracker.schedule = Set(schedule.map { NSNumber(value: $0.rawValue) }) as NSSet
        newTracker.category = categoryCoreData
        
        print("Сохраняю трекер")
        try context.save()
    }
    func debugPrintAllTrackers() {
        do {
            let coreDataTrackers = try context.fetch(TrackerCoreData.fetchRequest())
            print("Всего трекеров в БД: \(coreDataTrackers.count)")
            for tracker in coreDataTrackers {
                print("Трекер: \(tracker.name ?? "-") ID: \(tracker.id?.uuidString ?? "nil")")
            }
        } catch {
            print("Ошибка при отладке трекеров: \(error)")
        }
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeDidUpdateTrackersStore(self)
    }
}
