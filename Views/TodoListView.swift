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
    @State private var selectedCategory: CategoryFilter = .all

    enum CategoryFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case work = "Work"
        case personal = "Personal"
        case other = "Other"

        var id: String { rawValue }

        var todoCategory: TodoItem.Category? {
            switch self {
            case .all: return nil
            case .work: return .work
            case .personal: return .personal
            case .other: return .other
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                categorySelector

                ZStack(alignment: .bottomTrailing) {
                    ListViewForCategory(
                        category: selectedCategory.todoCategory,
                        viewModel: viewModel
                    )

                    floatingAddButton
                }
            }
            .navigationTitle("TodoMini")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingAddView) {
                AddTaskView(viewModel: viewModel)
            }
        }
    }

    // MARK: - 分类选择器（优化后对齐）
    private var categorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 12) {
                // 分类标签
                ForEach(CategoryFilter.allCases) { category in
                    categoryTab(for: category)
                }
                
                // 分隔线
                if viewModel.todos.contains(where: { $0.isCompleted }) {
                    Divider()
                        .frame(height: 24)
                        .opacity(0.5)
                }

                // 清除按钮
                if viewModel.todos.contains(where: { $0.isCompleted }) {
                    clearButton
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(
            Color(.systemBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
        )
    }

    // MARK: - 单个分类按钮
    private func categoryTab(for category: CategoryFilter) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedCategory = category
            }
        }) {
            VStack(spacing: 6) {
                Text(category.rawValue)
                    .font(.system(size: 15, weight: selectedCategory == category ? .semibold : .medium))
                    .foregroundColor(selectedCategory == category ? .primary : .secondary)

                // 底部指示器
                RoundedRectangle(cornerRadius: 1)
                    .frame(height: 2)
                    .foregroundColor(selectedCategory == category ? .blue : .clear)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .animation(.easeInOut(duration: 0.2), value: selectedCategory)
    }

    // MARK: - 清除按钮（重新设计）
    private var clearButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                viewModel.deleteCompletedTodos()
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: "trash.fill")
                    .font(.system(size: 12, weight: .medium))
                Text("Clear")
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(.red)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.red.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.red.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .scaleEffect(0.95)
        .animation(.easeInOut(duration: 0.1), value: viewModel.todos.contains(where: { $0.isCompleted }))
        .transition(.scale.combined(with: .opacity))
    }

    // MARK: - 悬浮添加按钮（增强设计）
    private var floatingAddButton: some View {
        Button(action: {
            showingAddView = true
        }) {
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, Color.blue.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .blue.opacity(0.4), radius: 12, x: 0, y: 6)
                        .shadow(color: .blue.opacity(0.2), radius: 4, x: 0, y: 2)
                )
        }
        .padding(.trailing, 24)
        .padding(.bottom, 32)
        .scaleEffect(showingAddView ? 0.92 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showingAddView)
    }
}

#Preview {
    TodoListView()
}
