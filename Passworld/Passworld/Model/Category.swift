//
//  Category.swift
//  Passworld
//
//  Created by luckly on 2025/12/2.
//

import Foundation
import SwiftData

@Model
final class Category {
    var name: String
    var iconName: String

    @Relationship(deleteRule: .cascade) var accounts = [Account]()

    init(name: String, iconName: String = "folder.fill", accounts: [Account] = [Account]()) {
        self.name = name
        self.iconName = iconName
        self.accounts = accounts
    }
}

extension Category {
    static func initializeDefaultCategories(in context: ModelContext, existingCategories: [Category]) {
        let defaultCategories = [
            ("全部", "lock.fill", []),
            ("收藏", "star.fill", []),
            ("教育", "graduationcap.fill", []),
            ("社交媒体", "person.2.fill", []),
            ("工作", "briefcase.fill", []),
            ("娱乐", "gamecontroller.fill", []),
            ("购物", "cart.fill", []),
            ("其他", "square.grid.2x2.fill", []),
        ]

        for (name, iconName, _) in defaultCategories {
            if !existingCategories.contains(where: { $0.name == name }) {
                let category = Category(name: name, iconName: iconName, accounts: [])
                context.insert(category)
            }
        }

        // 保存上下文
        do {
            try context.save()
        } catch {
            print("初始化默认分类失败: \(error.localizedDescription)")
        }
    }
}
