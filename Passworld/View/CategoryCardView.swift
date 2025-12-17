//
//  CategoryCardView.swift
//  Passworld
//
//  Created by luckly on 2025/12/2.
//

import SwiftData
import SwiftUI

// 为了在 HomeView 的 GridSection 中复用，我们创建一个通用的视图
// 它现在接受 Category 对象，但也可以用于硬编码的特殊卡片。

struct CategoryCardView: View {
    @EnvironmentObject var adaptiveManager: AdaptiveLayoutManager
    @Bindable var category: Category

    var iconColor: Color = .blue

    @Binding var selectedCategory: Category?

    var customCount: Int? = nil

    var displayedCount: Int {
        if let customCount {
            return customCount
        }
        return category.accounts.count
    }

    var body: some View {
        Button {
            selectedCategory = category // ✅ 修改：设置选中的分类
        } label: {
            VStack(alignment: .leading, spacing: adaptiveManager.spacing(5)) {
                HStack(alignment: .top) {
                    listIcon
                    Spacer()
                    Text("\(displayedCount)")
                        .font(.system(.largeTitle, design: .rounded).weight(.bold))
                        .foregroundColor(.primary)
                }
                .padding(.top, 5)

                Text(category.name)
                    .font(.system(.body, design: .rounded).weight(.bold))
                    .foregroundColor(.secondary)
            }
            .padding(10)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
        // ❌ 删除 navigationDestination
    }

    var listIcon: some View {
        ZStack {
            Circle()
                .fill(iconColor)
                .frame(width: adaptiveManager.width(30), height: adaptiveManager.height(30))
            Image(systemName: category.iconName)
                .font(.subheadline)
                .foregroundColor(.white)
                .bold()
        }
    }
}

// 示例用法（用于预览）
#Preview {
    let exampleCategory = Category(
        name: "社交媒体",
        iconName: "person.2.fill",
        accounts: [
            Account(serviceName: "Facebook", userName: "example", passwordHash: "hashed_pw_2", isFavorite: true),
            Account(serviceName: "Twitter", userName: "example", passwordHash: "hashed_pw_3", isFavorite: false),
            Account(serviceName: "Instagram", userName: "example", passwordHash: "hashed_pw_4", isFavorite: false),
        ]
    )
    let exampleSecurity = Category(
        name: "安全性",
        iconName: "exclamationmark.triangle.fill",
        accounts: [
            Account(serviceName: "Google", userName: "user1", passwordHash: "hashed_pw_1", isFavorite: false),
        ]
    )

    // ✅ 需要包裹在 NavigationStack 中，因为涉及导航
    NavigationStack {
        VStack(spacing: 20) {
            CategoryCardView(
                category: exampleCategory,
                iconColor: .blue, // ✅ 修复：使用英文逗号
                selectedCategory: .constant(nil) // ✅ 修复：使用 .constant(nil) 创建绑定
            )
            .frame(width: 150)

            CategoryCardView(
                category: exampleSecurity,
                iconColor: .red, // ✅ 修复：使用英文逗号
                selectedCategory: .constant(nil) // ✅ 添加：必需参数
            )
            .frame(width: 150)
        }
        .padding()
        .background(.black)
    }
    .preferredColorScheme(.dark)
}
