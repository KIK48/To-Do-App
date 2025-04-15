//
//  ContentView.swift
//  To-Do-App
//
//  Created by Kike Perez Alvarez on 4/1/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = TaskViewModel()
    @State private var isShowingAddSheet = false
    
    @State private var selectedTaskToEdit: Task?
    

    

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.tasks) { task in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(task.title)
                                .strikethrough(task.isDone)
                            Text("Due: \(task.due.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text(task.priority.rawValue.capitalized)
                            .padding(5)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(5)
                        Button(action: {
                            viewModel.toggleDone(task)
                        }) {
                            Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(task.isDone ? .green : .gray)
                        }
                        Button(role: .destructive) {
                            viewModel.deleteTaskById(task.id)
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                    .onTapGesture(count: 2) {
                        selectedTaskToEdit = task
                        
                    }
                }
            }


            .sheet(item: $selectedTaskToEdit) { task in
                AddTaskView(viewModel: viewModel, taskToEdit: task)
            }

            .navigationTitle("To-Do List")
            .toolbar {
                Button("Add") {
                    isShowingAddSheet = true
                }
            }
            .sheet(isPresented: $isShowingAddSheet) {
                AddTaskView(viewModel: viewModel)
            }
        }
    }
}

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TaskViewModel
    
    var taskToEdit: Task? = nil 

    @State private var title = ""
    @State private var dues = Date()
    @State private var priority: Priority = .medium
    
    init(viewModel: TaskViewModel, taskToEdit: Task? = nil) {
            self.viewModel = viewModel
            self.taskToEdit = taskToEdit
            _title = State(initialValue: taskToEdit?.title ?? "")
            _dues = State(initialValue: taskToEdit?.due ?? Date())
            _priority = State(initialValue: taskToEdit?.priority ?? .medium)
        }

    var body: some View {
        Form {
            TextField("Task Title", text: $title)
            DatePicker("Due Date", selection: $dues, displayedComponents: .date)
            Picker("Priority", selection: $priority) {
                ForEach(Priority.allCases, id: \.self) { p in
                    Text(p.rawValue.capitalized).tag(p)
                }
            }
            HStack {
                Button("Save Task") {
                    if let existingTask = taskToEdit {
                            // Editing → remove the old task, then add updated one
                            viewModel.deleteTaskById(existingTask.id)
                        }

                        let newTask = Task(title: title, due: dues, priority: priority)
                        viewModel.addTask(newTask)
                        dismiss()
                }
                Button("Cancel"){ dismiss() }
            }
            
        }
        .navigationTitle(taskToEdit == nil ? "Add Task" : "Edit Task")
    }
}


#Preview("AddTaskView") {
    AddTaskView(viewModel: .init())
}

#Preview("Content View") {
    ContentView()
        .frame(width: 800, height: 600)
}
