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
    @State private var priority: Int = 2
    @State private var notes: String = ""
    @State private var isStarred: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Add Task")
                    .font(.title)
                    .bold()

                TextField("Title", text: $title)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)

                Toggle("Important ⭐️", isOn: $isStarred)

                VStack(alignment: .leading) {
                    Text("Priority")
                        .font(.headline)
                    Picker("Priority", selection: $priority) {
                        Text("Low").tag(1)
                        Text("Medium").tag(2)
                        Text("High").tag(3)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                VStack(alignment: .leading) {
                    Text("Category")
                        .font(.headline)
                    Picker("Category", selection: $category) {
                        ForEach(TodoItem.Category.allCases) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                VStack(alignment: .leading) {
                    Text("Due Date")
                        .font(.headline)
                    DatePicker("Select Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                        .labelsHidden()
                }

                VStack(alignment: .leading) {
                    Text("Reminder")
                        .font(.headline)
                    DatePicker("Reminder", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                        .labelsHidden()
                }

                VStack(alignment: .leading) {
                    Text("Duration (minutes)")
                        .font(.headline)
                    Stepper("\(durationInMin) minutes", value: $durationInMin, in: 0...240, step: 5)
                }

                VStack(alignment: .leading) {
                    Text("Notes")
                        .font(.headline)
                    TextEditor(text: $notes)
                        .frame(height: 100)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                }

                Button(action: {
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
                }) {
                    Text("Save")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .disabled(title.isEmpty)
            }
            .padding()
        }
    }
}

#Preview {
    AddTaskView(viewModel: TodoViewModel())
}
