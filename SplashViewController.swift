import Foundation
import UIKit

class SplashViewController: UIViewController {
    
    private let imageView = UIImageView()
    
    override func viewDidLoad() {
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let mainTabBarViewController = MainTabBarViewController()
        
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = mainTabBarViewController
            window.makeKeyAndVisible()
        }
    }
    
    func setupUI() {
        let launchImage = UIImage(named: "launch_screen_logo")
        imageView.image = launchImage
        imageView.contentMode = .scaleAspectFill
        view.addSubview(imageView)
        view.backgroundColor = .ypBlue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)])
    }
}
