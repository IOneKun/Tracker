import Foundation
import UIKit
import CoreData


final class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    var context: NSManagedObjectContext {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate недоступен")
        }
        return delegate.persistentContainer.viewContext
    }
}
