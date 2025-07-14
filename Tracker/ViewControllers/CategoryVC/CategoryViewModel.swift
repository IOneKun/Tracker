import UIKit

final class CategoryViewModel {
    
    private let categoryStore: TrackerCategoryStore
    private(set) var categories: [String] = [] {
        didSet {
            onCategoriesChanged?()
        }
    }
    var selectedCategory: String?
    
    var onCategoriesChanged: (() -> Void)?
    
    init(categoryStore: TrackerCategoryStore = TrackerCategoryStore()) {
        self.categoryStore = categoryStore
        self.categoryStore.delegate = self
        self.categoryStore.setupFetchedResultsController()
        fetchCategories()
    }
    
    func fetchCategories() {
        do {
            let fetched = try categoryStore.fetchCategories()
            self.categories = fetched.compactMap { $0.name }
        } catch {
            print("\(error)")
        }
    }
    
    func addCategory(_ name: String) {
        do {
            try categoryStore.addTrackerCategory(with: name)
        } catch {
            print("\(error)")
        }
    }
    func selectedCategory(at index: Int) {
        selectedCategory = categories[index]
    }
}

extension CategoryViewModel: TrackerCategoryStoreDelegate {
    func storeDidUpdateTrackerCategories(_ store: TrackerCategoryStore) {
        fetchCategories() 
    }
}
