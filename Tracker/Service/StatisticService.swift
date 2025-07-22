import Foundation
import CoreData

final class StatisticsService {
    private let context: NSManagedObjectContext
    private let recordStore: TrackerRecordStore
    private let trackerStore: TrackerStore
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context,
         recordStore: TrackerRecordStore = TrackerRecordStore(),
         trackerStore: TrackerStore = TrackerStore()) {
        self.context = context
        self.recordStore = recordStore
        self.trackerStore = trackerStore
    }
    
    func fetchStatistics() -> (bestStreak: Int, perfectDays: Int, completedTrackers: Int, average: Int) {
        let allRecords = recordStore.allRecords()
        let allTrackers = trackerStore.allTrackers()
        
        let bestResult = calculateBestResult(records: allRecords)
        let perfectDays = calculatePerfectDays(records: allRecords, trackerCount: allTrackers.count)
        let completed = calculateCompletedTrackers(records: allRecords)
        let average = calculateAverage(records: allRecords, trackerCount: allTrackers.count)
        
        return (bestResult, perfectDays, completed, average)
    }
    
    private func calculateBestResult(records: [TrackerRecord]) -> Int {
        let groupedByTracker = Dictionary(grouping: records) { $0.trackerID }
        var maxStreak = 0
        
        for records in groupedByTracker.values {
            let sorted = records.map { $0.date }.sorted()
            var streak = 1
            var currentMax = 1
            
            for i in 1..<sorted.count {
                if Calendar.current.isDate(sorted[i], inSameDayAs: Calendar.current.date(byAdding: .day, value: 1, to: sorted[i - 1])!) {
                    streak += 1
                    currentMax = max(currentMax, streak)
                } else {
                    streak = 1
                }
            }
            maxStreak = max(maxStreak, currentMax)
        }
        return maxStreak
    }
    
    private func calculatePerfectDays(records: [TrackerRecord], trackerCount: Int) -> Int {
        guard trackerCount > 0 else { return 0 }
        
        let groupedByDate = Dictionary(grouping: records) { Calendar.current.startOfDay(for: $0.date) }
        return groupedByDate.values.filter { $0.count == trackerCount }.count
    }
    
    private func calculateCompletedTrackers(records: [TrackerRecord]) -> Int {
        let uniqueIDs = Set(records.map { $0.trackerID })
        return uniqueIDs.count
    }
    
    private func calculateAverage(records: [TrackerRecord], trackerCount: Int) -> Int {
        guard trackerCount > 0 else { return 0 }
        return Int(round(Double(records.count) / Double(trackerCount)))
    }
}

