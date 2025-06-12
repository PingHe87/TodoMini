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
        
        // 首先按分类过滤
        if let category = category {
            filtered = viewModel.todos.filter { $0.category == category }
        } else {
            filtered = viewModel.todos
        }
        
        // 然后按优先级 + 截止时间排序
        return filtered.sorted { todo1, todo2 in
            // 先按优先级排序（高优先级在前）
            let priority1 = todo1.priority ?? 0
            let priority2 = todo2.priority ?? 0
            if priority1 != priority2 {
                return priority1 > priority2
            }
            
            // 优先级相同时按截止时间排序
            switch (todo1.dueDate, todo2.dueDate) {
            case (nil, nil):
                // 两个都没有截止时间，按创建时间排序
                return todo1.createdAt < todo2.createdAt
            case (nil, _):
                // todo1没有截止时间，排到后面
                return false
            case (_, nil):
                // todo2没有截止时间，todo1排到前面
                return true
            case (let date1?, let date2?):
                // 两个都有截止时间，按截止时间排序
                return date1 < date2
            }
        }
    }

    var body: some View {
        List {
            ForEach(filteredTodos) { todo in
                NavigationLink(destination: TaskDetailView(viewModel: viewModel, todo: todo)) {
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(priorityColor(for: todo.priority).opacity(0.2))

                        RoundedRectangle(cornerRadius: 10)
                            .fill(priorityColor(for: todo.priority))
                            .frame(width: widthForDuration(todo.durationInMin))

                        HStack {
                            Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                                .onTapGesture {
                                    viewModel.toggleComplete(todo)
                                }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(todo.title)
                                    .strikethrough(todo.isCompleted)

                                if let due = todo.dueDate {
                                    Text("Due: \(due, formatter: dateFormatter)")
                                        .font(.caption)
                                        .foregroundColor(dueDateColor(for: due))
                                }

                                Text("Priority: \(priorityLabel(for: todo.priority))")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            if todo.isStarred {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    .padding(.vertical, 4)
                }
            }
            .onDelete { offsets in
                viewModel.deleteTodo(at: offsets, in: filteredTodos)
            }
        }
        .id(viewModel.refreshID)
    }

    func priorityColor(for level: Int?) -> Color {
        switch level {
        case 3: return .red       // High
        case 2: return .orange    // Medium
        case 1: return .green     // Low
        default: return .gray
        }
    }

    func priorityLabel(for level: Int?) -> String {
        switch level {
        case 3: return "High"
        case 2: return "Medium"
        case 1: return "Low"
        default: return "None"
        }
    }

    func widthForDuration(_ duration: Int?) -> CGFloat {
        let maxDuration: CGFloat = 120
        let baseWidth: CGFloat = 200
        guard let d = duration else { return 40 }
        let ratio = min(CGFloat(d) / maxDuration, 1.0)
        return baseWidth * ratio
    }
    
    // 根据截止时间返回颜色，让用户更容易识别紧急程度
    func dueDateColor(for dueDate: Date) -> Color {
        let now = Date()
        let timeInterval = dueDate.timeIntervalSince(now)
        let hoursUntilDue = timeInterval / 3600
        
        if hoursUntilDue < 0 {
            return .red        // 已过期
        } else if hoursUntilDue < 24 {
            return .orange     // 24小时内到期
        } else if hoursUntilDue < 72 {
            return .yellow     // 3天内到期
        } else {
            return .gray       // 还有时间
        }
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
