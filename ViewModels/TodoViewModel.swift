//
//  TodoViewModel.swift
//  TodoMini
//
//  Created by p h on 6/10/25.
//

import Foundation

class TodoViewModel: ObservableObject {
    @Published var todos: [TodoItem] = []

    private let saveKey = "TodoMiniTodos"

    init() {
        loadTodos()
    }

    // 添加任务
    func addTodo(title: String) {
        let newTodo = TodoItem(title: title)
        todos.append(newTodo)
        saveTodos()
    }

    // 删除任务
    func deleteTodo(at offsets: IndexSet, in filtered: [TodoItem]) {
        let idsToDelete = offsets.map { filtered[$0].id }
        todos.removeAll { idsToDelete.contains($0.id) }
        saveTodos()
    }


    // 更新完成状态
    func toggleComplete(_ todo: TodoItem) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index].isCompleted.toggle()
            saveTodos()
        }
    }

    // 删除所有已完成任务
    func deleteCompletedTodos() {
        todos.removeAll { $0.isCompleted }
        saveTodos()
    }

    @Published var refreshID = UUID()

    func updateTodo(_ updated: TodoItem) {
        if let index = todos.firstIndex(where: { $0.id == updated.id }) {
            todos[index] = updated
            saveTodos()
            refreshID = UUID() // 强制刷新视图
        }
    }

    // MARK: - 保存与加载

    func saveTodos() {
        do {
            let encoded = try JSONEncoder().encode(todos)
            UserDefaults.standard.set(encoded, forKey: saveKey)
        } catch {
            print("⚠️ Failed to encode todos: \(error)")
        }
    }

    func loadTodos() {
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            do {
                let decoded = try JSONDecoder().decode([TodoItem].self, from: data)
                self.todos = decoded
            } catch {
                print("⚠️ Failed to decode todos: \(error)")
                self.todos = []
            }
        }
    }
}

