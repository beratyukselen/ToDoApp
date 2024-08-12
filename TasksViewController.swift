//
//  TasksViewController.swift
//  TodoApp
//
//  Created by Berat Yükselen on 21.04.2024.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

private let reuseIdentifier = "TasksCell"

class TasksViewController: UIViewController {
    // MARK: - Properties
    var user: User? {
        didSet { configure() }
    }
    private var tasks = [Task]()
    private var filteredTasks = [Task]() 
    
    private lazy var newTaskButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus.diamond.fill"), for: .normal)
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleNewTaskButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var exportCSVButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Export CSV", for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleExportCSVButton), for: .touchUpInside)
        return button
    }()
    
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        return collectionView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.textColor = .white
        label.text = " "
        return label
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search Tasks"
        searchBar.searchBarStyle = .minimal
        return searchBar
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
        searchBar.delegate = self // Arama çubuğunun delegesini ayarla
    }
}

// MARK: - Service
extension TasksViewController {
    private func fetchTasks() {
        guard let uid = self.user?.uid else { return }
        Service.fetchTasks(uid: uid) { tasks in
            self.tasks = tasks
            self.filteredTasks = tasks // Filtrelenmiş görevleri başlangıçta tüm görevler olarak ayarla
            self.collectionView.reloadData()
        }
    }
}

// MARK: - Selector
extension TasksViewController {
    @objc private func handleNewTaskButton(_ sender: UIButton) {
        let controller = NewTaskViewController()
        if let sheet = controller.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        self.present(controller, animated: true)
    }
    
    @objc private func handleExportCSVButton(_ sender: UIButton) {
        let csvString = convertToCSV(tasks: tasks)
        saveCSVFile(contents: csvString, fileName: "tasks.csv")
    }
}

// MARK: - Helpers
extension TasksViewController {
    private func style() {
        backgroundGradientColor()
        self.navigationController?.navigationBar.isHidden = true
        newTaskButton.translatesAutoresizingMaskIntoConstraints = false
        exportCSVButton.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(TaskCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false // Arama çubuğunu düzenle
        view.addSubview(searchBar) // Arama çubuğunu view'a ekle
    }
    
    private func layout() {
        view.addSubview(collectionView)
        view.addSubview(newTaskButton)
        view.addSubview(nameLabel)
        view.addSubview(searchBar) // Move searchBar setup to the top
        view.addSubview(exportCSVButton)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            
            searchBar.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8), // Adjust the top anchor to nameLabel.bottomAnchor
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8), // Adjust the top anchor of collectionView to searchBar.bottomAnchor
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 14),
            
            newTaskButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30), // Adjust the bottom anchor of newTaskButton
            view.trailingAnchor.constraint(equalTo: newTaskButton.trailingAnchor, constant: 4),
            newTaskButton.heightAnchor.constraint(equalToConstant: 60),
            newTaskButton.widthAnchor.constraint(equalToConstant: 60),
            
            exportCSVButton.bottomAnchor.constraint(equalTo: newTaskButton.topAnchor, constant: -10), // CSV butonunu newTaskButton'ın üzerine yerleştir
            view.trailingAnchor.constraint(equalTo: exportCSVButton.trailingAnchor, constant: 4),
            exportCSVButton.heightAnchor.constraint(equalToConstant: 40),
            exportCSVButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }

    private func configure() {
        guard let user = self.user else { return }
        nameLabel.text = "Hi \(user.name) 👋🏻"
        fetchTasks()
    }
    
    private func convertToCSV(tasks: [Task]) -> String {
        var csvString = "TaskID,Text,Timestamp,IsDone\n"
        
        for task in tasks {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let timestampString = dateFormatter.string(from: task.timestamp.dateValue())
            let isDoneString = task.isDone ? "true" : "false"
            csvString.append("\(task.taskId),\(task.text),\(timestampString),\(isDoneString)\n")
        }
        
        return csvString
    }

    private func saveCSVFile(contents: String, fileName: String) {
        let fileManager = FileManager.default
        do {
            let path = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = path.appendingPathComponent(fileName)
            try contents.write(to: fileURL, atomically: true, encoding: .utf8)
            print("File saved: \(fileURL.absoluteString)")
            
            // Dosyayı paylaşma
            let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            present(activityViewController, animated: true, completion: nil)
        } catch {
            print("Error saving file: \(error)")
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension TasksViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredTasks.count // Filtrelenmiş görevleri say
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TaskCell
        cell.task = filteredTasks[indexPath.row] // Filtrelenmiş görevleri göster
        cell.index = indexPath.row
        cell.delegate = self
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TasksViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cell = TaskCell(frame: .init(x: 0, y: 0, width: view.frame.width * 0.9, height: 50))
        cell.task = filteredTasks[indexPath.row] // Filtrelenmiş görevleri boyutlandır
        cell.layoutIfNeeded()
        let copySize = cell.systemLayoutSizeFitting(.init(width: view.frame.width * 0.9, height: 1000))
        return .init(width: view.frame.width * 0.9, height: copySize.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: 10, height: 10)
    }
}

// MARK: - TaskCellProtocol
extension TasksViewController: TaskCellProtocol {
    func deleteTask(sender: TaskCell, index: Int) {
        sender.reload()
        guard index >= 0 && index < tasks.count else {
            print("Hatalı indeks: \(index)")
            return
        }
        let task = tasks[index]
        tasks[index].isDone = true // Görevi tamamlandı olarak işaretle
        
        // Filtrelenmiş diziden de tamamlanan görevi kaldır
        if let filteredIndex = filteredTasks.firstIndex(where: { $0.taskId == task.taskId }) {
            filteredTasks.remove(at: filteredIndex)
        }
        
        self.collectionView.reloadData() // collectionView'ı yenile
    }
}

// MARK: - UISearchBarDelegate
extension TasksViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterTasks(with: searchText) // Arama metni değiştiğinde görevleri filtrele
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filterTasks(with: nil) // Arama iptal edildiğinde tüm görevleri göster
    }
}

// MARK: - Helpers
extension TasksViewController {
    private func filterTasks(with searchText: String?) {
        if let text = searchText, !text.isEmpty {
            let filteredTasks = tasks.filter { task in
                return task.text.lowercased().contains(text.lowercased())
            }
            self.filteredTasks = filteredTasks
        } else {
            self.filteredTasks = tasks
        }
        collectionView.reloadData() // Filtrelenmiş görevleri collectionView'a yükle
    }
}

