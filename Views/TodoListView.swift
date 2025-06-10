//
//  TodoListView.swift
//  TodoMini
//
//  Created by p h on 6/10/25.
//

import SwiftUI

struct TodoListView: View {
    @StateObject private var viewModel = TodoViewModel()
    @State private var showingAddView = false
    @State private var selectedCategory: TodoItem.Category? = nil

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                // 横向滑动切换分类任务页
                TabView(selection: $selectedCategory) {
                    ListViewForCategory(category: nil, viewModel: viewModel)
                        .tag(nil as TodoItem.Category?)
                    ForEach(TodoItem.Category.allCases) { category in
                        ListViewForCategory(category: category, viewModel: viewModel)
                            .tag(category as TodoItem.Category?)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

                // 底部分类栏 + 添加按钮（美化样式）
                VStack(spacing: 12) {
                    // 居中的底部分类栏
                    HStack(spacing: 8) {
                        CategoryChip(label: "Work", isSelected: selectedCategory == .work) {
                            withAnimation { selectedCategory = .work }
                        }
                        CategoryChip(label: "Personal", isSelected: selectedCategory == .personal) {
                            withAnimation { selectedCategory = .personal }
                        }
                        CategoryChip(label: "All", isSelected: selectedCategory == nil) {
                            withAnimation { selectedCategory = nil }
                        }
                        CategoryChip(label: "Other", isSelected: selectedCategory == .other) {
                            withAnimation { selectedCategory = .other }
                        }
                    }

                    // 居中悬浮添加按钮
                    Button(action: {
                        showingAddView = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color.blue))
                            .shadow(radius: 6)
                    }
                }
                .padding(.bottom, 30)
            }
            .navigationTitle("TodoMini")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Delete Completed Tasks") {
                        viewModel.deleteCompletedTodos()
                    }
                    .padding(.top, 30)
                }
            }
            .sheet(isPresented: $showingAddView) {
                AddTaskView(viewModel: viewModel)
            }
        }
    }
}

struct CategoryChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(isSelected ? .white : .blue)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(Color.blue.opacity(isSelected ? 0 : 1), lineWidth: 1)
                )
                .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
    }
}

#Preview {
    TodoListView()
}
