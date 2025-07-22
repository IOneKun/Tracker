import UIKit

class StatisticViewController: UIViewController {
    
    //MARK: - Variables
    
    var color = Color()
    
    private var metrics: [(value: Int, title: String, gradient: [UIColor])] = []
    
    private let mockEmptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализировать пока нечего"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let labelTracker: UILabel = {
        let label = UILabel()
        label.text = "Статистика"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = 16
            layout.itemSize = CGSize(width: view.bounds.width - 32, height: 90)

            let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
            cv.translatesAutoresizingMaskIntoConstraints = false
            cv.dataSource = self
            cv.backgroundColor = .systemBackground
            cv.register(StatisticsCell.self, forCellWithReuseIdentifier: StatisticsCell.reuseIdentifier)
            return cv
        }()
    
    let imageView = UIImageView()
    
    private let statsService = StatisticsService()
    
    //MARK: - Lilfecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let stats = statsService.fetchStatistics()
        
        let color1 = UIColor(named: "color1") ?? .red
        let color2 = UIColor(named: "color5") ?? .green
        let color3 = UIColor(named: "color3") ?? .blue
        
        metrics = [
            (stats.bestStreak, "Лучший период", [color1, color2, color3]),
            (stats.perfectDays, "Идеальные дни", [color1, color2, color3]),
            (stats.completedTrackers, "Трекеров завершено", [color1, color2, color3]),
            (stats.average, "Среднее значение", [color1, color2, color3])
        ]
        
        updateViewVisibility()
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        view.backgroundColor = color.viewBackgroundColor
        setupMockImageAndLabelOnTrackerVC()
        setupNavBarLabel()
        setupLayout()
    }
    
    //MARK: - Functions
    
    private func updateViewVisibility() {
        
        let hasData = metrics.contains { $0.value > 0 }
        
        collectionView.isHidden = !hasData
        imageView.isHidden = hasData
        mockEmptyLabel.isHidden = hasData
    }
    
    func setupMockImageAndLabelOnTrackerVC() {
        let image = UIImage(named: "cry_emoji")
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        view.addSubview(mockEmptyLabel)
        NSLayoutConstraint.activate([
            mockEmptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mockEmptyLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8)
        ])
    }
    
    private func setupLayout() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: labelTracker.bottomAnchor, constant: 77),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
     func setupNavBarLabel() {
     view.addSubview(labelTracker)
     
     NSLayoutConstraint.activate([
     labelTracker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
     labelTracker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
     labelTracker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)])
     }
     
}

//MARK: - UICollectionViewDataSource

extension StatisticViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return metrics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StatisticsCell.reuseIdentifier, for: indexPath) as! StatisticsCell
        let metric = metrics[indexPath.item]
        cell.configure(value: metric.value, title: metric.title, gradientColors: metric.gradient)
        return cell
    }
}
