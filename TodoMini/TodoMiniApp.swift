//
//  TodoMiniApp.swift
//  TodoMini
//
//  Created by p h on 6/10/25.
//

import SwiftUI

@main
struct TodoMiniApp: App {
    var body: some Scene {
        WindowGroup {
            TodoListView() // ← 用我们刚写好的视图替换原来的 ContentView
        }
    }
}

