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
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Edit Task")
                    .font(.title)
                    .bold()
                    .padding(.bottom, 10)

                TextField("Title", text: $todo.title)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)

                VStack(alignment: .leading) {
                    Text("Priority")
                        .font(.headline)
                    Picker("Priority", selection: Binding(
                        get: { todo.priority ?? 2 },
                        set: { todo.priority = $0 }
                    )) {
                        Text("Low").tag(1)
                        Text("Medium").tag(2)
                        Text("High").tag(3)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                VStack(alignment: .leading) {
                    Text("Category")
                        .font(.headline)
                    Picker("Category", selection: Binding(
                        get: { todo.category ?? .personal },
                        set: { todo.category = $0 }
                    )) {
                        ForEach(TodoItem.Category.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                VStack(alignment: .leading) {
                    Text("Due Date")
                        .font(.headline)
                    DatePicker("Select Date", selection: Binding(
                        get: { todo.dueDate ?? Date() },
                        set: { todo.dueDate = $0 }
                    ), displayedComponents: [.date, .hourAndMinute])
                    .labelsHidden()
                }

                VStack(alignment: .leading) {
                    Text("Duration (minutes)")
                        .font(.headline)
                    TextField("Duration", value: Binding(
                        get: { todo.durationInMin ?? 0 },
                        set: { todo.durationInMin = $0 }
                    ), formatter: NumberFormatter())
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                }

                VStack(alignment: .leading) {
                    Text("Notes")
                        .font(.headline)
                    TextEditor(text: Binding(
                        get: { todo.notes ?? "" },
                        set: { todo.notes = $0 }
                    ))
                    .frame(height: 100)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                }

                Toggle("Starred", isOn: $todo.isStarred)
                Toggle("Completed", isOn: $todo.isCompleted)

                Button(action: {
                    viewModel.updateTodo(todo)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.top)
            }
            .padding()
        }
    }
}
