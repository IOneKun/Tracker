import UIKit

class MainTabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trackersVC = UINavigationController(rootViewController: TrackersViewController())
        trackersVC.tabBarItem = UITabBarItem(title: "Трекеры",
                                             image: UIImage(named: "tracker_bar_item"),
                                             selectedImage: nil)
        
        let statisticVC = UINavigationController(rootViewController: StatisticViewController())
        statisticVC.tabBarItem = UITabBarItem(title: "Статистика",
                                              image: UIImage(named: "statistic_bar_item"),
                                              selectedImage: nil)
        
        self.viewControllers = [trackersVC, statisticVC]
    }
}

