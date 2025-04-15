//
//  task.swift
//  To-Do-App
//
//  Created by Kike Perez Alvarez on 4/1/25.
//

import Foundation

enum Priority: String, Codable, CaseIterable {
    case low, medium, high
}

struct Task: Identifiable, Codable {
    
    var id = UUID()
    var title: String
    var due: Date
    var priority: Priority
    var isDone: Bool = false
    
}

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    let savePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("tasks.json")

    init() {
        loadTasks()
    }

    func addTask(_ task: Task) {
        tasks.append(task)
        saveTasks()
    }

    func toggleDone(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isDone.toggle()
            saveTasks()
        }
    }

    func saveTasks() {
        do {
            let data = try JSONEncoder().encode(tasks)
            try data.write(to: savePath)
        } catch {
            print("Error saving tasks: \(error)")
        }
    }

    func loadTasks() {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: savePath.path) {
            do {
                let data = try Data(contentsOf: savePath)
                tasks = try JSONDecoder().decode([Task].self, from: data)
            } catch {
                print("Error decoding tasks: \(error)")
            }
        } else {
            print("tasks.json not found – likely first launch. No tasks to load yet.")
        }
    }
    
    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
        saveTasks()
    }
    
    func deleteTaskById(_ id: UUID) {
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            tasks.remove(at: index)
            saveTasks()
        }
    }


}
