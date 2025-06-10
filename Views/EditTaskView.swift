//
//  EditTaskView.swift
//  TodoMini
//
//  Created by p h on 6/10/25.
//

import SwiftUI

struct EditTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: TodoViewModel
    @State var todo: TodoItem

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Title")) {
                    TextField("Title", text: $todo.title)
                }

                Section(header: Text("Category")) {
                    Picker("Category", selection: Binding(
                        get: { todo.category ?? .personal },
                        set: { todo.category = $0 }
                    )) {
                        ForEach(TodoItem.Category.allCases) { category in
                            Text(category.rawValue.capitalized).tag(category)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("Due Date")) {
                    DatePicker("", selection: Binding(
                        get: { todo.dueDate ?? Date() },
                        set: { todo.dueDate = $0 }
                    ), displayedComponents: [.date, .hourAndMinute])
                }

                Section(header: Text("Notes")) {
                    TextEditor(text: Binding(
                        get: { todo.notes ?? "" },
                        set: { todo.notes = $0 }
                    ))
                        .frame(height: 100)
                }

                Section {
                    Toggle("Starred", isOn: $todo.isStarred)
                    Toggle("Completed", isOn: $todo.isCompleted)
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarItems(trailing: Button("Save") {
                viewModel.updateTodo(todo)
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
