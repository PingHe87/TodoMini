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
        var filtered: [TodoItem]
        
        if let category = category {
            filtered = viewModel.todos.filter { $0.category == category }
        } else {
            filtered = viewModel.todos
        }
        
        return filtered.sorted { todo1, todo2 in
            // 已完成的任务排到最后
            if todo1.isCompleted != todo2.isCompleted {
                return !todo1.isCompleted
            }
            
            // 星标任务优先
            if todo1.isStarred != todo2.isStarred {
                return todo1.isStarred
            }
            
            // 按优先级排序
            let priority1 = todo1.priority ?? 0
            let priority2 = todo2.priority ?? 0
            if priority1 != priority2 {
                return priority1 > priority2
            }
            
            // 按截止时间排序
            switch (todo1.dueDate, todo2.dueDate) {
            case (nil, nil):
                return todo1.createdAt > todo2.createdAt  // 修改：最新创建的在前面
            case (nil, _):
                return false
            case (_, nil):
                return true
            case (let date1?, let date2?):
                return date1 < date2  // 截止时间早的在前面，晚的在后面
            }
        }
    }

    var body: some View {
        List {
            ForEach(filteredTodos) { todo in
                NavigationLink(destination: TaskDetailView(viewModel: viewModel, todo: todo)) {
                    TodoCardView(todo: todo, viewModel: viewModel)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .onDelete { offsets in
                viewModel.deleteTodo(at: offsets, in: filteredTodos)
            }
        }
        .listStyle(PlainListStyle())
        .id(viewModel.refreshID)
    }
}

struct TodoCardView: View {
    let todo: TodoItem
    @ObservedObject var viewModel: TodoViewModel
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                // 左侧：完成状态按钮
                completionButton
                
                // 中间：任务内容
                VStack(alignment: .leading, spacing: 6) {
                    // 任务标题
                    taskTitle
                    
                    // 任务详情（时间、分类等）
                    taskDetails
                }
                
                Spacer()
                
                // 右侧：星标和优先级
                rightSection
            }
            .padding(16)
            .background(cardBackground)
            .overlay(priorityIndicator, alignment: .leading)
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onTapGesture {
            // 处理点击动画
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }
    }
    
    // MARK: - 完成状态按钮
    private var completionButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.toggleComplete(todo)
            }
        }) {
            ZStack {
                Circle()
                    .stroke(
                        todo.isCompleted ? priorityColor : Color.gray.opacity(0.3),
                        lineWidth: 2
                    )
                    .frame(width: 24, height: 24)
                
                if todo.isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(priorityColor)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - 任务标题
    private var taskTitle: some View {
        Text(todo.title)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(todo.isCompleted ? .secondary : .primary)
            .strikethrough(todo.isCompleted, color: .secondary)
            .lineLimit(2)
            .animation(.easeInOut(duration: 0.2), value: todo.isCompleted)
    }
    
    // MARK: - 改进的到期时间显示组件
    @ViewBuilder
    private var dueDateView: some View {
        if let dueDate = todo.dueDate {
            HStack(spacing: 4) {
                Image(systemName: dueDateIcon(for: dueDate))
                    .font(.system(size: 11, weight: .medium))
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(formatDueDateMain(dueDate))
                        .font(.system(size: 12, weight: .semibold))
                    
                    if shouldShowTime(for: dueDate) {
                        Text(formatDueDateTime(dueDate))
                            .font(.system(size: 10, weight: .regular))
                            .opacity(0.8)
                    }
                }
            }
            .foregroundColor(dueDateColor(for: dueDate))
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(dueDateColor(for: dueDate).opacity(0.08))
            )
        }
    }
    
    // MARK: - 任务详情
    private var taskDetails: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 一行显示：截止时间、预估时长、分类
            HStack(spacing: 8) {
                // 截止时间
                dueDateView
                
                // 预估时长标签
                if let duration = todo.durationInMin, duration > 0 {
                    let isQuickTask = duration <= 30
                    HStack(spacing: 4) {
                        Image(systemName: isQuickTask ? "bolt.fill" : "timer")
                            .font(.system(size: 11))
                        Text(formatDuration(duration))
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(isQuickTask ? .orange : .blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill((isQuickTask ? Color.orange : Color.blue).opacity(0.08))
                    )
                }
                
                // 分类标签
                if let category = todo.category {
                    Text(category.rawValue)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.gray.opacity(0.08))
                        )
                }
                
                Spacer()
            }
        }
    }
    
    // MARK: - 右侧区域
    private var rightSection: some View {
        VStack(alignment: .trailing, spacing: 8) {
            // 星标
            if todo.isStarred {
                Image(systemName: "star.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.yellow)
            }
            
            // 优先级指示器（小圆点）
            if let priority = todo.priority, priority > 0 {
                Circle()
                    .fill(priorityColor)
                    .frame(width: 8, height: 8)
            }
        }
    }
    
    // MARK: - 卡片背景
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemBackground))
            .shadow(
                color: Color.black.opacity(todo.isCompleted ? 0.02 : 0.06),
                radius: todo.isCompleted ? 2 : 8,
                x: 0,
                y: todo.isCompleted ? 1 : 2
            )
            .opacity(todo.isCompleted ? 0.7 : 1.0)
    }
    
    // MARK: - 优先级指示条
    private var priorityIndicator: some View {
        Rectangle()
            .fill(priorityColor)
            .frame(width: 4)
            .clipShape(
                .rect(
                    topLeadingRadius: 12,
                    bottomLeadingRadius: 12,
                    bottomTrailingRadius: 0, topTrailingRadius: 0
                )
            )
            .opacity(todo.priority != nil && todo.priority! > 0 ? 1 : 0)
    }
    
    // MARK: - 辅助方法
    private var priorityColor: Color {
        switch todo.priority {
        case 3: return .red
        case 2: return .orange
        case 1: return .green
        default: return .gray
        }
    }
    
    // MARK: - 改进的日期格式化方法
    private func formatDueDateMain(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDate(date, inSameDayAs: now) {
            return "Today"
        } else if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now),
                  calendar.isDate(date, inSameDayAs: tomorrow) {
            return "Tomorrow"
        } else if let yesterday = calendar.date(byAdding: .day, value: -1, to: now),
                  calendar.isDate(date, inSameDayAs: yesterday) {
            return "Yesterday"
        } else {
            let daysDifference = calendar.dateComponents([.day], from: now, to: date).day ?? 0
            
            if daysDifference > 0 && daysDifference <= 7 {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE" // 星期几
                return formatter.string(from: date)
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "M/d"
                return formatter.string(from: date)
            }
        }
    }
    
    private func formatDueDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func shouldShowTime(for date: Date) -> Bool {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        
        // 如果时间不是00:00，则显示具体时间
        return !(components.hour == 0 && components.minute == 0)
    }
    
    private func dueDateIcon(for dueDate: Date) -> String {
        let now = Date()
        let timeInterval = dueDate.timeIntervalSince(now)
        let hoursUntilDue = timeInterval / 3600
        
        if hoursUntilDue < 0 {
            return "exclamationmark.triangle.fill" // 已过期
        } else if hoursUntilDue < 2 {
            return "alarm.fill" // 紧急
        } else if hoursUntilDue < 24 {
            return "clock.fill" // 今天内
        } else {
            return "calendar" // 未来日期
        }
    }
    
    // MARK: - 改进的颜色逻辑
    private func dueDateColor(for dueDate: Date) -> Color {
        let now = Date()
        let timeInterval = dueDate.timeIntervalSince(now)
        let hoursUntilDue = timeInterval / 3600
        
        if hoursUntilDue < 0 {
            return .red // 已过期
        } else if hoursUntilDue < 2 {
            return .red.opacity(0.9) // 2小时内 - 紧急
        } else if hoursUntilDue < 24 {
            return .orange // 24小时内 - 重要
        } else if hoursUntilDue < 72 {
            return .blue // 3天内 - 正常
        } else {
            return .secondary // 较远的日期 - 次要
        }
    }
    
    private func formatDuration(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes)min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            if remainingMinutes == 0 {
                return "\(hours)h"
            } else {
                return "\(hours)h \(remainingMinutes)m"
            }
        }
    }
}

#Preview {
    ListViewForCategory(category: nil, viewModel: TodoViewModel())
}
