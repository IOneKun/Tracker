import Foundation
import AppMetricaCore

enum AnalyticsEvent {
    case open(screen: String)
    case close(screen: String)
    case click(screen: String, item: String)

    var parameters: [AnyHashable: Any] {
        switch self {
        case .open(let screen):
            return ["event": "open", "screen": screen]
        case .close(let screen):
            return ["event": "close", "screen": screen]
        case .click(let screen, let item):
            return ["event": "click", "screen": screen, "item": item]
        }
    }

    var name: String {
        return "event"
    }
}

final class AnalyticsService {
    static let shared = AnalyticsService()

    private init() {}

    func report(_ event: AnalyticsEvent) {
        print("Reporting event: \(event.parameters)")
        AppMetrica.reportEvent(name: event.name, parameters: event.parameters)
    }
}
