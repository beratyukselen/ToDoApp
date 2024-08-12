//
//  NewTaskViewController.swift
//  TodoApp
//
//  Created by Berat Yükselen on 29.04.2024.
//

import UIKit
import Firebase

class NewTaskViewController: UIViewController {
    // MARK: - Properties
    private let newTaskLabel: UILabel = {
        let label = UILabel()
        label.attributedText = NSMutableAttributedString(string: "New Task",attributes: [.foregroundColor: UIColor.white, .font: UIFont.preferredFont(forTextStyle: .largeTitle)])
        label.textAlignment = .center
        return label
    }()
    
    private let textView: InputTextView = {
        let inputTextView = InputTextView()
        inputTextView.placeHolder = "Enter New Task.."
        return inputTextView
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        return picker
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = .systemRed
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleCancelButton), for: .touchUpInside)
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return button
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = .mainColor
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleAddButton), for: .touchUpInside)
        return button
    }()
    
    private var stackView = UIStackView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
    }
    
    // MARK: - Selector
    @objc private func handleCancelButton(){
        self.dismiss(animated: true)
    }
    
    // MARK: - Selector
    @objc private func handleAddButton(){
        guard let taskText = textView.text else { return }
        let selectedDate = datePicker.date
        
        // Add task to Firestore
        Service.sendTask(text: taskText) { error in
            if let error = error {
                print("Error sending task to Firestore: \(error.localizedDescription)")
            } else {
                // Firebase notification setup
                let notificationContent = UNMutableNotificationContent()
                notificationContent.title = "New Task Reminder"
                notificationContent.body = "Don't forget: \(taskText)"
                notificationContent.sound = UNNotificationSound.default
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: selectedDate), repeats: false)
                
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Error adding notification request: \(error.localizedDescription)")
                    } else {
                        print("Notification request added successfully!")
                    }
                }
            }
        }
        
        self.dismiss(animated: true)
    }

    
    // MARK: - Helpers
    private func style(){
        view.backgroundColor = .black.withAlphaComponent(0.7)
        newTaskLabel.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        stackView = UIStackView(arrangedSubviews: [cancelButton, addButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 6
        stackView.distribution = .fillEqually
    }
    
    private func layout(){
        view.addSubview(newTaskLabel)
        view.addSubview(textView)
        view.addSubview(datePicker)
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            newTaskLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            newTaskLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            view.trailingAnchor.constraint(equalTo: newTaskLabel.trailingAnchor, constant: 32),
            newTaskLabel.heightAnchor.constraint(equalToConstant: 60),
            
            textView.topAnchor.constraint(equalTo: newTaskLabel.bottomAnchor, constant: 8),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            view.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: 16),
            textView.heightAnchor.constraint(equalToConstant: view.bounds.height / 5),
            
            datePicker.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 8),
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            view.trailingAnchor.constraint(equalTo: datePicker.trailingAnchor, constant: 16),
            
            stackView.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            view.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 16)
        ])
    }
}
