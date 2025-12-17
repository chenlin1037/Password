//
//  AccountDetailView.swift
//  Passworld
//
//  Created by luckly on 2025/12/8.
//
import SwiftData
import SwiftUI
#if canImport(UIKit)
    import UIKit
#endif

struct AccountDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var account: Account

    @State private var isEditing = false
    @State private var editedServiceName: String = ""
    @State private var editedUserName: String = ""
    @State private var editedPassword: String = ""
    @State private var editedNotes: String = ""
    @State private var showPassword = false
    @State private var currentPlainPassword: String = ""
    @State private var showCopyAlert = false

    @Query private var categories: [Category]
    @State private var selectedCategoryID: PersistentIdentifier?

    private var canSave: Bool {
        !editedServiceName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !editedUserName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("网站或标签")
                    Spacer()
                    if isEditing {
                        TextField("网站或标签", text: $editedServiceName)
                            .multilineTextAlignment(.trailing)
                    } else {
                        Text(account.serviceName)
                            .foregroundColor(.secondary)
                    }
                }

                HStack {
                    Text("用户")
                    Spacer()
                    if isEditing {
                        TextField("用户名", text: $editedUserName)
                            .multilineTextAlignment(.trailing)
                    } else {
                        Text(account.userName)
                            .foregroundColor(.secondary)
                    }
                }

                HStack {
                    Text("密码")
                    Spacer()
                    Group {
                        if isEditing {
                            if showPassword {
                                TextField("留空表示不修改", text: $editedPassword)
                                    .multilineTextAlignment(.trailing)
                            } else {
                                SecureField("留空表示不修改", text: $editedPassword)
                                    .multilineTextAlignment(.trailing)
                            }
                        } else {
                            if showPassword {
                                Text(currentPlainPassword.isEmpty ? "无密码" : currentPlainPassword)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            } else {
                                Text("••••••••")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .onTapGesture {
                        showPassword.toggle()
                    }
                    .onLongPressGesture {
                        copyPassword()
                    }
                }
            }
            if isEditing {
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
            }
            Section(header: Text("备注")) {
                if isEditing {
                    TextEditor(text: $editedNotes)
                        .frame(minHeight: 80)
                } else {
                    if account.notes.isEmpty {
                        Text("暂无备注")
                            .foregroundColor(.secondary)
                    } else {
                        Text(account.notes)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle(account.serviceName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    toggleFavorite()
                } label: {
                    Image(systemName: account.isFavorite ? "star.fill" : "star")
                        .foregroundColor(account.isFavorite ? .yellow : .secondary)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(isEditing ? "保存" : "编辑") {
                    if isEditing {
                        saveChanges()
                    } else {
                        startEditing()
                    }
                }
                .disabled(isEditing && !canSave)
            }
        }
        .onAppear {
            loadInitialValues()
            markAsUsed()
            if selectedCategoryID == nil {
                if let current = account.category, current.name != "全部" {
                    selectedCategoryID = current.id
                } else if let first = selectableCategories.first {
                    selectedCategoryID = first.id
                }
            }
        }
        .alert("已复制", isPresented: $showCopyAlert) {} message: {
            Text("密码已复制到剪贴板")
        }
    }

    private func loadInitialValues() {
        editedServiceName = account.serviceName
        editedUserName = account.userName
        editedPassword = ""
        editedNotes = account.notes
        showPassword = false
        currentPlainPassword = Account.loadPassword(for: account) ?? ""
    }

    private func markAsUsed() {
        account.lastUsedAt = Date()
        try? modelContext.save()
    }

    private func startEditing() {
        loadInitialValues()
        isEditing = true
    }

    private func saveChanges() {
        let trimmedService = editedServiceName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedUser = editedUserName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedService.isEmpty, !trimmedUser.isEmpty else { return }

        account.serviceName = trimmedService
        account.userName = trimmedUser
        account.notes = editedNotes

        if let id = selectedCategoryID,
           let newCategory = categories.first(where: { $0.id == id })
        {
            if let oldCategory = account.category, oldCategory.id != newCategory.id {
                if let index = oldCategory.accounts.firstIndex(where: { $0.id == account.id }) {
                    _ = oldCategory.accounts.remove(at: index)
                }
            }
            account.category = newCategory
            if !newCategory.accounts.contains(where: { $0.id == account.id }) {
                newCategory.accounts.append(account)
            }
        }

        if !editedPassword.isEmpty {
            let hashed = Account.hashedPassword(editedPassword)
            account.passwordHash = hashed
            Account.savePassword(editedPassword, for: account)
            currentPlainPassword = editedPassword
        }

        try? modelContext.save()
        isEditing = false
    }

    private var selectableCategories: [Category] {
        categories.filter { $0.name != "全部" }
    }

    private func copyPassword() {
        #if canImport(UIKit)
            var didCopy = false
            if isEditing {
                if !editedPassword.isEmpty {
                    UIPasteboard.general.string = editedPassword
                    didCopy = true
                } else if !currentPlainPassword.isEmpty {
                    UIPasteboard.general.string = currentPlainPassword
                    didCopy = true
                }
            } else if !currentPlainPassword.isEmpty {
                UIPasteboard.general.string = currentPlainPassword
                didCopy = true
            }

            if didCopy {
                showCopyAlert = true
            }
        #endif
    }

    private func toggleFavorite() {
        account.isFavorite.toggle()
        try? modelContext.save()
    }
}
