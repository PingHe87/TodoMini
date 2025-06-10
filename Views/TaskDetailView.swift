//
//  TaskDetailView.swift
//  TodoMini
//
//  Created by p h on 6/10/25.
//

import SwiftUI

struct TaskDetailView: View {
    @ObservedObject var viewModel: TodoViewModel
    @State private var showingEditView = false
    var todo: TodoItem

    var body: some View {
        Form {
            Section(header: Text("Title")) {
                Text(todo.title)
            }

            Section(header: Text("Category")) {
                Text(todo.category?.rawValue.capitalized ?? "None")
            }

            if let due = todo.dueDate {
                Section(header: Text("Due Date")) {
                    Text(due.formatted(date: .abbreviated, time: .shortened))
                }
            }

            if let reminder = todo.reminderDate {
                Section(header: Text("Reminder")) {
                    Text(reminder.formatted(date: .abbreviated, time: .shortened))
                }
            }

            if let duration = todo.durationInMin {
                Section(header: Text("Duration")) {
                    Text("\(duration) minutes")
                }
            }

            if let priority = todo.priority {
                Section(header: Text("Priority")) {
                    Text("\(priority)")
                }
            }

            if let notes = todo.notes, !notes.isEmpty {
                Section(header: Text("Notes")) {
                    Text(notes)
                }
            }

            Section {
                HStack {
                    Text("Starred")
                    Spacer()
                    Image(systemName: todo.isStarred ? "star.fill" : "star")
                        .foregroundColor(todo.isStarred ? .yellow : .gray)
                }

                HStack {
                    Text("Completed")
                    Spacer()
                    Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(todo.isCompleted ? .green : .gray)
                }
            }

            Section {
                Button("Edit Task") {
                    showingEditView = true
                }
            }
        }
        .navigationTitle("Task Details")
        .sheet(isPresented: $showingEditView) {
            EditTaskView(viewModel: viewModel, todo: todo)
        }
    }
}
