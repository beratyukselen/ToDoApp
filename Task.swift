//
//  Task.swift
//  TodoApp
//
//  Created by Berat Yükselen on 21.04.2024.
//

import FirebaseFirestore

struct Task {
    let taskId: String
    let text: String
    let timestamp: Timestamp
    var isDone: Bool
    var doneTimestamp: Timestamp? // Görev tamamlandığında kullanılacak timestamp

    init(data: [String: Any]) {
        self.taskId = data["taskId"] as? String ?? ""
        self.text = data["text"] as? String ?? ""
        self.timestamp = data["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.isDone = data["isDone"] as? Bool ?? false // Varsayılan olarak false
        self.doneTimestamp = data["doneTimestamp"] as? Timestamp // Görev tamamlandığında belirtilen tarih
    }
}
