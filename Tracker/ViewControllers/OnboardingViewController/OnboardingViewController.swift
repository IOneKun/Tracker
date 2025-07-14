import UIKit

class OnboardingViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var onFinish: (() -> Void)?
    
    private lazy var pages: [UIViewController] = {
        return [
            {
                let page1 = PageViewController(
                    imageName: "onboarding_page_1",
                    message: "Отслеживайте только то, что хотите")
                
                page1.onFinish = { [weak self] in self?.onFinish?() }
                return page1
            }(),
            {
                let page2 = PageViewController(
                    imageName: "onboarding_page_2",
                    message: "Даже если это не литры воды и йога")
                
                page2.onFinish = { [weak self] in self?.onFinish?() }
                return page2
            }()
        ]
    }()
    
    
    private let pageControl = UIPageControl()
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        
        setupPageControl()
    }
    
    private func setupPageControl() {
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        let previousIndex = index - 1
        return previousIndex >= 0 ? pages[previousIndex] : pages.last
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        let nextIndex = index + 1
        return nextIndex < pages.count ? pages[nextIndex] : pages.first
    }
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}
