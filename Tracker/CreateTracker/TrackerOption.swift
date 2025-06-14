import Foundation
import UIKit

enum TrackerOptionType: CaseIterable {
    case category
    case schedule
    
    var title: String {
        switch self {
        case .category: return "Категория"
        case .schedule: return "Расписание"
        }
    }
    
    var value: String {
        return ""
    }
}
