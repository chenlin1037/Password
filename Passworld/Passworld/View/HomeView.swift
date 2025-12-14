//
//  HomeView.swift
//  Passworld
//
//  Created by luckly on 2025/12/3.
//

import SwiftData
import SwiftUI

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var adaptiveManager: AdaptiveLayoutManager
    // 查询所有的用户自定义 Category(群组)
    @Query var categories: [Category]

    @StateObject private var viewModel = HomeViewModel()

    let colums = [GridItem(.adaptive(minimum: 150))] // 网格布局

    // 计算属性:所有账户的总数 (用于"全部"卡片)
    var totalAccountCount: Int {
        // 遍历所有用户群组,然后将所有账户数组展平并计数
        viewModel.totalAccountCount(categories: categories)
    }

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

    var suggestedAccounts: [Account] {
        let text = viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let accounts = allAccounts

        if text.isEmpty {
            let used = accounts.filter { $0.lastUsedAt != nil }
            if !used.isEmpty {
                let sorted = used.sorted { ($0.lastUsedAt ?? Date.distantPast) > ($1.lastUsedAt ?? Date.distantPast) }
                return Array(sorted.prefix(10))
            } else {
                // 首次使用时还没有“最近使用”，则按创建时间倒序展示部分账号
                let sorted = accounts.sorted { $0.createAt > $1.createAt }
                return Array(sorted.prefix(10))
            }
        } else {
            let filtered = accounts.filter {
                $0.serviceName.localizedCaseInsensitiveContains(text) ||
                    $0.userName.localizedCaseInsensitiveContains(text)
            }
            return filtered.sorted {
                $0.serviceName.localizedCaseInsensitiveCompare($1.serviceName) == .orderedAscending
            }
        }
    }

    var fixedCategories: [Category] {
        let desiredOrder = ["全部", "收藏", "教育", "社交媒体", "工作", "娱乐", "购物", "其他"]
        let filtered = categories.filter { desiredOrder.contains($0.name) }
        return filtered.sorted {
            (desiredOrder.firstIndex(of: $0.name) ?? desiredOrder.count) <
                (desiredOrder.firstIndex(of: $1.name) ?? desiredOrder.count)
        }
    }

    var body: some View {
        NavigationStack {
            mainContent
                .navigationTitle("密码") // 导航栏标题
                // 1. 全局搜索栏
                .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "搜索") {
                    ForEach(suggestedAccounts) { account in
                        Button {
                            viewModel.selectedAccountFromSearch = account
                        } label: {
                            AccountRowView(account: account)
                        }
                    }
                }
                .navigationDestination(
                    item: Binding(
                        get: { viewModel.selectedCategory },
                        set: { viewModel.selectedCategory = $0 }
                    )
                ) { category in
                    AccountListView(category: category)
                }
                .navigationDestination(
                    item: Binding(
                        get: { viewModel.selectedAccountFromSearch },
                        set: { viewModel.selectedAccountFromSearch = $0 }
                    )
                ) { account in
                    AccountDetailView(account: account)
                }
                // 2. 底部工具栏/添加按钮
                .safeAreaInset(edge: .bottom) {
                    HStack {
                        Spacer()
                        Button {
                            // 触发添加新账号的 Alert
                            viewModel.showAddAccountsheet = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 25))
                                .foregroundColor(.blue)
                        }
                        .padding()
                    }
                    .background(Color.clear)
                }

                
        }
        .sheet(isPresented: Binding(
            get: { viewModel.showAddAccountsheet },
            set: { viewModel.showAddAccountsheet = $0 }
        )) {
            let sheetBinding = Binding(
                get: { viewModel.showAddAccountsheet },
                set: { viewModel.showAddAccountsheet = $0 }
            )

            if let allCategory = categories.first(where: { $0.name == "全部" }) {
                AddAccountView(showAddAccountsheet: sheetBinding, targetCategory: allCategory)
            } else if let firstCategory = categories.first {
                AddAccountView(showAddAccountsheet: sheetBinding, targetCategory: firstCategory)
            } else {
                // 理论上 .onAppear 中会初始化默认分类
                // 如果这里仍然没有任何分类，就给出一个简单提示视图
                Text("暂无可用群组，请稍后重试")
            }
        }
        .onAppear {
            viewModel.ensureDefaultCategories(in: modelContext, existingCategories: categories)
        }
    }

    private var mainContent: some View {
        List {
            gridSection
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - 1. 特殊卡片网格区域

    private var gridSection: some View {
        let selectedCategoryBinding = Binding<Category?>(
            get: { viewModel.selectedCategory },
            set: { viewModel.selectedCategory = $0 }
        )

        return Section {
            LazyVGrid(columns: colums, spacing: adaptiveManager.spacing(10)) {
                ForEach(fixedCategories) { category in
                    CategoryCardView(
                        category: category,
                        iconColor: color(for: category),
                        selectedCategory: selectedCategoryBinding,
                        customCount: customCount(for: category)
                    )
                    .frame(height: 100)
                }
            }
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
    }

    private func color(for category: Category) -> Color {
        switch category.name {
        case "全部":
            return .blue
        case "收藏":
            return .yellow
        case "教育":
            return .red
        case "社交媒体":
            return .orange
        case "工作":
            return .green
        case "娱乐":
            return .purple
        case "购物":
            return .pink
        case "其他":
            return .gray
        default:
            return .blue
        }
    }

    private func customCount(for category: Category) -> Int? {
        switch category.name {
        case "全部":
            return allAccounts.count
        case "收藏":
            return favoriteAccounts.count
        default:
            return nil
        }
    }
}
