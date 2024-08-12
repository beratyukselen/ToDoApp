import UIKit
import Firebase

private let reuseIdentifier = "PastTaskCell"

class PastTaskViewController: UIViewController {
    
    // MARK: - Properties
    var user: User? {
        didSet { configureUser() }
    }
    
    private var pastTasks: [Task]? {
        didSet { self.collectionView.reloadData() }
    }
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PastTaskCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
    }
    
    // MARK: - Service
    private func fetchTasks(uid: String) {
        Service.fetchPastTasks(uid: uid) { tasks in
            self.pastTasks = tasks
        }
    }
    
    // MARK: - Helpers
    private func style() {
        backgroundGradientColor()
    }
    
    private func layout() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 14)
        ])
        
        // Export CSV button
        let exportButton = UIBarButtonItem(title: "Export CSV", style: .plain, target: self, action: #selector(exportCSV))
        navigationItem.rightBarButtonItem = exportButton
    }
    
    private func configureUser() {
        guard let user = self.user else { return }
        fetchTasks(uid: user.uid)
    }
    
    @objc private func exportCSV() {
        guard let pastTasks = self.pastTasks else { return }
        writeToCSV(tasks: pastTasks)
    }
    
    private func writeToCSV(tasks: [Task]) {
        var csvText = "Task Name,Task Description,Completion Date\n" // CSV başlıkları güncellendi
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Tarih ve saat formatı
        
        for task in tasks {
            var dateString = "Not Completed"
            if let doneTimestamp = task.doneTimestamp {
                dateString = dateFormatter.string(from: doneTimestamp.dateValue())
            }
            let newLine = "\(task.text),\(task.taskId),\(dateString)\n" // Tarih ve saat eklendi
            csvText.append(newLine)
        }
        
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = documentsURL.appendingPathComponent("pastTasks.csv")
        
        do {
            try csvText.write(to: fileURL, atomically: true, encoding: .utf8)
            print("CSV dosyası başarıyla oluşturuldu: \(fileURL)")
            
            // Dosyayı telefon galerisine kaydet
            let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            present(activityViewController, animated: true, completion: nil)
        } catch {
            print("CSV dosyasına yazılırken bir hata oluştu: \(error)")
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension PastTaskViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.pastTasks?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PastTaskCell
        cell.task = self.pastTasks?[indexPath.row]
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PastTaskViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cell = PastTaskCell(frame: .init(x: 0, y: 0, width: view.frame.width * 0.9, height: 50))
        cell.task = pastTasks![indexPath.row]
        cell.layoutIfNeeded()
        let copySize = cell.systemLayoutSizeFitting(.init(width: view.frame.width * 0.9, height: 1000))
        return .init(width: view.frame.width * 0.9, height: copySize.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: 10, height: 10)
    }
}

