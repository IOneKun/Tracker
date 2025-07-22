import CoreData
import UIKit

protocol TrackerStoreDelegate: AnyObject {
    func storeDidUpdateTrackersStore(_ store: TrackerStore)
}

final class TrackerStore: NSObject {
    
    weak var delegate: TrackerStoreDelegate?
    
    var context: NSManagedObjectContext!
    var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    
    init (context: NSManagedObjectContext) {
        self.context = context
    }
    convenience override init() {
        let context = CoreDataManager.shared.context
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
        
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("\(error)")
        }
    }
    func fetchTrackers() throws -> [TrackerCoreData] {
        guard let objects = fetchedResultsController?.fetchedObjects else {
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
    func deleteTracker(withId id: UUID) {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            if let trackerToDelete = try context.fetch(fetchRequest).first {
                context.delete(trackerToDelete)
                try context.save()
                print("Трекер удалён успешно")
            } else {
                print("Трекер с таким id не найден")
            }
        } catch {
            print("Ошибка при удалении трекера: \(error)")
        }
    }
    func trackerCoreData(with id: UUID) -> TrackerCoreData? {
        return fetchedResultsController?.fetchedObjects?.first(where: { $0.id == id })
    }
    func allTrackers() -> [Tracker] {
        guard let objects = fetchedResultsController?.fetchedObjects else {
            return []
        }

        var trackers: [Tracker] = []

        for coreData in objects {
            guard
                let id = coreData.id,
                let name = coreData.name,
                let emoji = coreData.emoji,
                let colorHex = coreData.color,
                let scheduleSet = coreData.schedule as? Set<NSNumber>
            else {
                continue
            }

            guard let color = UIColor.fromHex(colorHex) else {
                continue
            }
            
            let schedule = scheduleSet.compactMap { Weekday(rawValue: $0.intValue) }

            let tracker = Tracker(
                id: id,
                name: name,
                emoji: emoji,
                color: color,
                schedule: schedule
            )

            trackers.append(tracker)
        }

        return trackers
    }

}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeDidUpdateTrackersStore(self)
    }
}
