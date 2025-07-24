import XCTest
import SnapshotTesting
@testable import Tracker
import Testing


final class TrackersSnapshotTests: XCTestCase {

    func testTrackersViewController() {
        let vc = TrackersViewController()
        

        vc.view.frame = UIScreen.main.bounds
        
       
        vc.loadViewIfNeeded()
       
        vc.selectedDate = Date()
        

        assertSnapshot(of: vc, as: .image)
    }
}

