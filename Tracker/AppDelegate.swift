import UIKit
import CoreData
import AppMetricaCore

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Error loading CoreData store: \(error.localizedDescription)")
            }
        }
        return container
    }()
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        DaysValueTransformer.register()
        
        let apiKey = "b3247476-ff2a-4d18-897d-d7bc7c47086d"
        guard !apiKey.isEmpty else {
            print("AppMetrica API key is empty")
            return false
        }
        
        guard let configuration = AppMetricaConfiguration(apiKey: apiKey) else {
            print("Failed to create AppMetrica configuration")
            return false
        }
        
        AppMetrica.activate(with: configuration)
        print("AppMetrica activated")
        
        return true
    }
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
