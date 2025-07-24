import UIKit

final class MainTabBarViewController: UITabBarController {
    let color = Color() 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .whiteDay
        
        let trackersVC = UINavigationController(rootViewController: TrackersViewController())
        
        let title = NSLocalizedString("tab_tracker", comment: "")
        trackersVC.tabBarItem = UITabBarItem(title: title,
                                             image: UIImage(named: "tracker_bar_item"),
                                             selectedImage: nil)
        
        let statisticVC = UINavigationController(rootViewController: StatisticViewController())
        
        let statisticTitle = NSLocalizedString("tab_statistic", comment: "")
        statisticVC.tabBarItem = UITabBarItem(title: statisticTitle,
                                              image: UIImage(named: "statistic_bar_item"),
                                              selectedImage: nil)
        
        self.viewControllers = [trackersVC, statisticVC]

        
        if #available(iOS 15.0, *) {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground() 
            tabBarAppearance.backgroundColor = color.viewBackgroundColor
            
            tabBar.standardAppearance = tabBarAppearance
            tabBar.scrollEdgeAppearance = tabBarAppearance
        }

    }
}

