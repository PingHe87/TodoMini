//
//  TodoItem.swift
//  TodoMini
//
//  Created by p h on 6/10/25.
//

import Foundation

struct TodoItem: Identifiable, Codable {
    var id = UUID()                     // 唯一标识
    var title: String                   // 任务标题
    var isCompleted: Bool = false       // 是否完成
    
    var createdAt: Date = Date()        // 创建时间
    var dueDate: Date? = nil            // 截止时间
    var reminderDate: Date? = nil       // 提醒时间
    var durationInMin: Int? = nil       // 持续时间（分钟）
    
    enum Category: String, Codable, CaseIterable, Identifiable {
        case work = "Work"
        case personal = "Personal"
        case other = "Other"
        
        var id: String { rawValue }
    }

    var category: Category? = nil

    var priority: Int? = nil            // 优先级（1-5）
    var notes: String? = nil            // 备注
    var isStarred: Bool = false         // 是否标星/置顶
}
