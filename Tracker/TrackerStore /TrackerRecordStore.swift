import Foundation

final class TrackerRecordStore1 {
    private(set) var records: [TrackerRecord] = []
    
    func addRecord(_ record: TrackerRecord) {
        records.append(record)
    }
    
    func removeRecord(for trackerId: UUID, on date: Date) {
        records.removeAll() {
            $0.trackerID == trackerId && Calendar.current.isDate($0.date, inSameDayAs: date)
        }
    }
    func isTrackerCompleted(_ trackerId: UUID, on date: Date) -> Bool {
        return records.contains {
            $0.trackerID == trackerId && Calendar.current.isDate($0.date, inSameDayAs: date)
        }
    }
    func completedDaysCount(for trackerId: UUID) -> Int {
        return records.filter { $0.trackerID == trackerId }.count
    }
}


