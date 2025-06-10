//
//  ListViewForCategory.swift
//  TodoMini
//
//  Created by p h on 6/10/25.
//

import SwiftUI

struct ListViewForCategory: View {
    let category: TodoItem.Category?
    @ObservedObject var viewModel: TodoViewModel

    var filteredTodos: [TodoItem] {
        if let category = category {
            return viewModel.todos.filter { $0.category == category }
        } else {
            return viewModel.todos
        }
    }

    var body: some View {
        List {
            ForEach(filteredTodos) { todo in
                NavigationLink(destination: TaskDetailView(viewModel: viewModel, todo: todo)) {
                    HStack {
                        Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                            .onTapGesture {
                                viewModel.toggleComplete(todo)
                            }

                        VStack(alignment: .leading) {
                            Text(todo.title)
                                .strikethrough(todo.isCompleted)
                            if let due = todo.dueDate {
                                Text("Due: \(due, formatter: dateFormatter)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }

                        Spacer()

                        if todo.isStarred {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                }
            }
            .onDelete { offsets in
                viewModel.deleteTodo(at: offsets, in: filteredTodos)
            }
        }
        .id(viewModel.refreshID) // 强制刷新列表
    }
}

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

#Preview {
    ListViewForCategory(category: nil, viewModel: TodoViewModel())
}
