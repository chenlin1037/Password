//
//  AddAccountView.swift
//  Passworld
//
//  Created by luckly on 2025/12/4.
//

import SwiftData
import SwiftUI

// 用于管理哪个输入框当前处于焦点状态
private enum AccountField: Hashable {
    case serviceName
    case userName
    case password
    case notes
}

struct AddAccountView: View {
    // 注入 ModelContext 用于保存数据
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var adaptiveManager: AdaptiveLayoutManager
    @Environment(\.dismiss) var dismiss

    // 此视图是通过  sheet 弹出
    @Binding var showAddAccountsheet: Bool

    // 焦点状态：用于控制键盘自动弹出
    @FocusState private var focusedField: AccountField?

    // MARK: - 状态变量 (用户输入)

    @StateObject private var viewModel = AddAccountViewModel()

    @Query var categories: [Category]

    @State private var selectedCategoryID: PersistentIdentifier?

    // 接收目标 Category，以便将新账户添加到正确的群组中
    // 默认分组为“全部”
    var targetCategory: Category 

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - 第一部分：图标、网站/标签、用户名、密码

                Section {
                    HStack(spacing: 15) {
                        // 1. 图标占位符 (截图中的钥匙图标)
                        Image(systemName: "key.fill")
                            .font(.title)
                            .padding(8)
                            .foregroundColor(.white)
                            .background(
                                LinearGradient(colors: [.blue, .white], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                        // 2. 网站或标签 (Service Name) 输入框
                        // 注意：这里使用 TextField 模拟截图中的样式
                        TextField("网站或标签", text: $viewModel.serviceName)
                            .focused($focusedField, equals: .serviceName)
                    }

                    // 用户名
                    HStack {
                        Text("用户")
                            .foregroundColor(.primary)

                        Spacer() // 关键：撑开空间，让输入框靠右

                        TextField("用户名", text: $viewModel.userName)
                            .multilineTextAlignment(.trailing) // 输入框内容右对齐（可选）
                            .focused($focusedField, equals: .userName)
                    }

                    // 密码
                    HStack {
                        Text("密码")
                            .foregroundColor(.primary)

                        Spacer()

                        SecureField("密码", text: $viewModel.password)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField, equals: .password)
                    }
                }

                if !selectableCategories.isEmpty {
                    Section {
                        Picker("群组", selection: Binding(
                            get: { selectedCategoryID },
                            set: { selectedCategoryID = $0 }
                        )) {
                            ForEach(selectableCategories) { category in
                                Text(category.name).tag(category.id as PersistentIdentifier?)
                            }
                        }
                    }
                }

                // MARK: - 第二部分：备注

                Section(header: Text("备注")) {
                    ZStack(alignment: .topLeading) {
                        // 占位符（当 notes 为空时显示）
                        if viewModel.notes.isEmpty {
                            Text("添加备注")
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }

                        TextEditor(text: $viewModel.notes)
                            .frame(minHeight: adaptiveManager.height(80))
                            .focused($focusedField, equals: .notes)
                            .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("新建密码")
            .navigationBarTitleDisplayMode(.inline)

            // MARK: - 工具栏/导航栏按钮

            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("存储") {
                        saveAccount()
                    }
                    // 只有服务名称、用户名和密码不为空时才启用存储按钮
                    .disabled(!viewModel.canSave)
                }
            }

            // MARK: - 自动弹出键盘

            .onAppear {
                // 视图出现后，自动将焦点设置到第一个输入框，弹出键盘
                focusedField = .serviceName

                if selectedCategoryID == nil {
                    if let matched = selectableCategories.first(where: { $0.id == targetCategory.id && targetCategory.name != "全部" }) {
                        selectedCategoryID = matched.id
                    } else if let first = selectableCategories.first {
                        selectedCategoryID = first.id
                    } else {
                        selectedCategoryID = categories.first?.id
                    }
                }
            }
        }
    }

    // MARK: - 核心功能函数

    func saveAccount() {
        let resolvedCategory: Category
        if let id = selectedCategoryID, let picked = categories.first(where: { $0.id == id }) {
            resolvedCategory = picked
        } else if let first = selectableCategories.first {
            resolvedCategory = first
        } else {
            resolvedCategory = targetCategory
        }

        let success = viewModel.saveAccount(to: resolvedCategory, in: modelContext)
        if success {
            dismiss()
        }
    }

    var selectableCategories: [Category] {
        categories.filter { $0.name != "全部" && $0.name != "收藏" }
    }
}

// MARK: - Preview

//#Preview {
//    AddAccountView(showAddAccountsheet: .constant(true), targetCategory: <#Category#>)
//}
