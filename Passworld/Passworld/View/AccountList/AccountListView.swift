//
//  AccountListView.swift
//  Passworld
//
//  Created by luckly on 2025/12/3.
//

import SwiftData
import SwiftUI
#if canImport(UIKit)
    import UIKit
#endif

struct AccountListView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) private var dismiss
    // 接收当前分组（Category）
    @Bindable var category: Category
    @Query var categories: [Category]

    @State private var showAddAccountsheet: Bool = false

    @StateObject private var viewModel = AccountListViewModel()

    // MARK: - 计算属性: 排序和分组

    var allAccounts: [Account] {
        var seen = Set<PersistentIdentifier>()
        var result: [Account] = []
        for category in categories {
            for account in category.accounts where !seen.contains(account.id) {
                seen.insert(account.id)
                result.append(account)
            }
        }
        return result
    }

    var favoriteAccounts: [Account] {
        allAccounts.filter { $0.isFavorite }
    }

    // 搜索过滤后的账户列表，并按服务名称排序
    var filteredAccounts: [Account] {
        if category.name == "全部" {
            return viewModel.filteredAccounts(fromAccounts: allAccounts)
        } else if category.name == "收藏" {
            return viewModel.filteredAccounts(fromAccounts: favoriteAccounts)
        } else {
            return viewModel.filteredAccounts(from: category)
        }
    }

    // 按首字母对账户进行分组
    var groupedAccounts: [String: [Account]] {
        if category.name == "全部" {
            return viewModel.groupedAccounts(fromAccounts: allAccounts)
        } else if category.name == "收藏" {
            return viewModel.groupedAccounts(fromAccounts: favoriteAccounts)
        } else {
            return viewModel.groupedAccounts(from: category)
        }
    }

    // 获取已排序的分组键（A, B, C...）
    var sortedKeys: [String] {
        if category.name == "全部" {
            return viewModel.sortedKeys(fromAccounts: allAccounts)
        } else if category.name == "收藏" {
            return viewModel.sortedKeys(fromAccounts: favoriteAccounts)
        } else {
            return viewModel.sortedKeys(from: category)
        }
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 1. 大标题 (例如截图中的 "全部")
//            Text(category.name)
//                .font(.system(.largeTitle, design: .rounded).bold())
//                .padding(.horizontal)
//                .padding(.bottom, 10)

            // 2. 账户列表，按字母分组
            List {
                ForEach(sortedKeys, id: \.self) { key in
                    Section(header: Text(key)) {
                        ForEach(groupedAccounts[key] ?? []) { account in
                            if viewModel.isSelectionMode {
                                HStack(spacing: 15) {
                                    Image(systemName: viewModel.selectedAccountIDs.contains(account.id) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(viewModel.selectedAccountIDs.contains(account.id) ? .blue : .secondary)
                                    AccountRowView(account: account)
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    toggleSelection(for: account)
                                }
                            } else {
                                // 使用 NavigationLink 导航到账户详情/编辑页
                                NavigationLink {
                                    AccountDetailView(account: account)
                                } label: {
                                    AccountRowView(account: account)
                                }
                            }
                        }
                        // 删除功能
                        .onDelete(perform: { indexSet in
                            delete(indexSet, from: groupedAccounts[key] ?? [])
                        })
                    }
                }
            }
            // 使用 .plain 列表样式以匹配截图中的无边框、分组样式
            .listStyle(.plain)
        }
        // 保持大标题在 VStack 中，而不是导航栏中
//        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.large)
        // 3. 搜索栏
        .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "搜索")
        // .navigationBarBackButtonHidden(true)
        // 4. 工具栏
        .toolbar {
            // ToolbarItem(placement: .navigationBarLeading) {
            //     Button(action: {
            //         dismiss()
            //     }) {
            //         HStack(spacing: 4) {
            //             Image(systemName: "chevron.left")
            //                 .font(.system(size: 16, weight: .medium))
            //         }
            //         .foregroundColor(.blue) // 自定义颜色，可以改为你想要的颜色
            //     }
            // }
            // 顶部工具栏右侧按钮（例如：排序/筛选按钮）
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    toggleSelectionMode()
                } label: {
                    if viewModel.isSelectionMode {
                        Text("取消")
                    } else {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }

            // 底部工具栏
            ToolbarItemGroup(placement: .bottomBar) {
                if viewModel.isSelectionMode {
                    Button(role: .destructive) {
                        deleteSelectedAccounts()
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(viewModel.selectedAccountIDs.isEmpty ? .gray : .red)
                    }
                    .disabled(viewModel.selectedAccountIDs.isEmpty)

                    Spacer()

                    Text("\(viewModel.selectedAccountIDs.count) 个项目")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Button {
                        toggleSelectAllVisible()
                    } label: {
                        Text(viewModel.selectedAccountIDs.count == filteredAccounts.count && !filteredAccounts.isEmpty ? "取消全选" : "全选")
                    }
                } else {
                    // 排序/筛选按钮（蓝色图标）
                    Menu {
                        Button {
                            viewModel.sortOption = .nameAsc
                        } label: {
                            HStack {
                                Text("名称 A → Z")
                                if viewModel.sortOption == .nameAsc {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }

                        Button {
                            viewModel.sortOption = .nameDesc
                        } label: {
                            HStack {
                                Text("名称 Z → A")
                                if viewModel.sortOption == .nameDesc {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .foregroundColor(.blue)
                    }

                    Spacer()

                    // 总项目数
                    Text("\(filteredAccounts.count) 个项目")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    // 添加账户按钮（蓝色大图标）
                    Button {
                        // viewModel.showingAddAlert = true
                        showAddAccountsheet = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .toolbarBackground(
            Color(.systemBackground).opacity(0.75),
            for: .bottomBar
        )

        .sheet(isPresented: $showAddAccountsheet) {
            if let Category = categories.first(where: { $0.name == category.name }) {
                AddAccountView(showAddAccountsheet: $showAddAccountsheet, targetCategory: Category)
            } else if let firstCategory = categories.first {
                AddAccountView(showAddAccountsheet: $showAddAccountsheet, targetCategory: firstCategory)
            } else {
                // 理论上 .onAppear 中会初始化默认分类
                // 如果这里仍然没有任何分类，就给出一个简单提示视图
                Text("暂无可用群组，请稍后重试")
            }
        }
    }

    // MARK: - 核心功能函数

    // 添加账户
    func addAccount() {
        viewModel.addAccount(to: category, in: modelContext)
    }

    // MARK: - 选择模式相关

    func toggleSelection(for account: Account) {
        viewModel.toggleSelection(for: account)
    }

    func toggleSelectionMode() {
        viewModel.toggleSelectionMode()
    }

    func deleteSelectedAccounts() {
        viewModel.deleteSelectedAccounts(in: category, context: modelContext)
    }

    func toggleSelectAllVisible() {
        viewModel.toggleSelectAllVisible(filteredAccounts: filteredAccounts)
    }

    // 分组列表中的删除操作（需要找到账户在主数组中的索引并删除）
    func delete(_ indexSet: IndexSet, from accountsInSection: [Account]) {
        viewModel.delete(indexSet, from: accountsInSection, in: category, context: modelContext)
    }
}

// MARK: - AccountDetailView 占位符

#Preview {
    // 1. 设置临时的 ModelContainer
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Category.self, Account.self, configurations: config)

        // 2. 创建预览数据
        let categoryAll = Category(name: "全部", iconName: "lock.fill")

        let accountA1 = Account(serviceName: "Facebook", userName: "chenlin", passwordHash: "hashed_pw_2", isFavorite: true)
        let accountA2 = Account(serviceName: "Github", userName: "chenlin", passwordHash: "hashed_pw_2", isFavorite: true)
        let accountA3 = Account(serviceName: "Twitter", userName: "chenlin", passwordHash: "hashed_pw_2", isFavorite: true)
        let accountA4 = Account(serviceName: "Instagram", userName: "chenlin", passwordHash: "hashed_pw_2", isFavorite: true)
        let accountA5 = Account(serviceName: "Telegram", userName: "chenlin", passwordHash: "hashed_pw_2", isFavorite: true)
        let accountB1 = Account(serviceName: "Google", userName: "chenlin", passwordHash: "hashed_pw_2", isFavorite: false)

        // 将账户添加到分类中
        categoryAll.accounts.append(contentsOf: [accountA1, accountA2, accountA3, accountA4, accountA5, accountB1])

        // 3. 将数据插入到上下文
        container.mainContext.insert(categoryAll)

        // 4. 返回 NavigationStack 包裹的 AccountListView
        return NavigationStack {
            AccountListView(category: categoryAll)
                // 确保预览器以深色模式显示，匹配截图风格
                .preferredColorScheme(.dark)
                // 设置容器，否则 @Bindable 无法工作
                .modelContainer(container)
        }

    } catch {
        // 错误处理，返回一个占位视图
        return Text("Failed to create preview container: \(error.localizedDescription)")
    }
}
