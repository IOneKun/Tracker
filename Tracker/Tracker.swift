import Foundation

struct Tracker {
    let id: UUID
    let name: String
    let emoji: String
    let color: String
    let schedule: [Weekday]
}

enum Weekday: String, CaseIterable {
    case Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday
}
