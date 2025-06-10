//
//  AddTaskView.swift
//  TodoMini
//
//  Created by p h on 6/10/25.
//

import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TodoViewModel

    @State private var title: String = ""
    @State private var dueDate: Date = Date()
    @State private var reminderDate: Date = Date()
    @State private var durationInMin: Int = 0
    @State private var category: TodoItem.Category = .personal
    @State private var priority: Int = 1
    @State private var notes: String = ""
    @State private var isStarred: Bool = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task")) {
                    TextField("Title", text: $title)
                    Toggle("Important ⭐️", isOn: $isStarred)
                }

                Section(header: Text("Time")) {
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("Reminder", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                    Stepper("Duration: \(durationInMin) min", value: $durationInMin, in: 0...240, step: 5)
                }

                Section(header: Text("More")) {
                    Picker("Category", selection: $category) {
                        ForEach(TodoItem.Category.allCases) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }

                    Picker("Priority", selection: $priority) {
                        ForEach(1...5, id: \.self) { level in
                            Text("Priority \(level)")
                        }
                    }
                    TextField("Notes", text: $notes, axis: .vertical)
                }
            }
            .navigationTitle("Add Task")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newTodo = TodoItem(
                            title: title,
                            isCompleted: false,
                            createdAt: Date(),
                            dueDate: dueDate,
                            reminderDate: reminderDate,
                            durationInMin: durationInMin,
                            category: category,
                            priority: priority,
                            notes: notes,
                            isStarred: isStarred
                        )
                        viewModel.todos.append(newTodo)
                        viewModel.saveTodos()
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AddTaskView(viewModel: TodoViewModel())
}
