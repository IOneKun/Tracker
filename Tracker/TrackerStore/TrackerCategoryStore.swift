import UIKit
import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func storeDidUpdateTrackerCategories(_ store: TrackerCategoryStore)
}

final class TrackerCategoryStore: NSObject {
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    var context: NSManagedObjectContext
    var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    convenience override init() {
        let context = CoreDataManager.shared.context
        self.init(context: context)
    }
    
    func setupFetchedResultsController() {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName:"TrackerCategoryCoreData")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
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
    func fetchCategories() throws -> [TrackerCategoryCoreData] {
        guard let objects = fetchedResultsController?.fetchedObjects else {
            return []
        }
        return objects
    }
    func addTrackerCategory(with name: String) throws {
        let newTrackerCategory = TrackerCategoryCoreData(context: context)
        newTrackerCategory.name = name
        try context.save()
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeDidUpdateTrackerCategories(self)
    }
}
