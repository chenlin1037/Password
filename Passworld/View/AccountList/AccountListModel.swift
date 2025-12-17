import Foundation
import SwiftData
import SwiftUI

final class AccountListViewModel: ObservableObject {
    @Published var showingAddAlert = false
    @Published var newServiceName = ""
    @Published var newUserName = ""
    @Published var newPassword = ""
    @Published var searchText = ""

    @Published var isSelectionMode = false
    @Published var selectedAccountIDs = Set<PersistentIdentifier>()

    enum SortOption: Equatable {
        case nameAsc
        case nameDesc
    }

    @Published var sortOption: SortOption = .nameAsc

    private func sortKey(for account: Account) -> String {
        let name = account.serviceName
        if let latin = name.applyingTransform(.toLatin, reverse: false)?.applyingTransform(.stripCombiningMarks, reverse: false) {
            return latin.uppercased()
        } else {
            return name.uppercased()
        }
    }

    func filteredAccounts(from category: Category) -> [Account] {
        filteredAccounts(fromAccounts: Array(category.accounts))
    }

    func filteredAccounts(fromAccounts accounts: [Account]) -> [Account] {
        var accounts = accounts

        if !searchText.isEmpty {
            accounts = accounts.filter {
                $0.serviceName.localizedCaseInsensitiveContains(searchText) ||
                    $0.userName.localizedCaseInsensitiveContains(searchText)
            }
        }

        switch sortOption {
        case .nameAsc:
            return accounts.sorted { sortKey(for: $0).localizedCaseInsensitiveCompare(sortKey(for: $1)) == .orderedAscending }
        case .nameDesc:
            return accounts.sorted { sortKey(for: $0).localizedCaseInsensitiveCompare(sortKey(for: $1)) == .orderedDescending }
        }
    }

    func groupedAccounts(from category: Category) -> [String: [Account]] {
        groupedAccounts(fromAccounts: Array(category.accounts))
    }

    func groupedAccounts(fromAccounts accounts: [Account]) -> [String: [Account]] {
        let accounts = filteredAccounts(fromAccounts: accounts)
        return Dictionary(grouping: accounts) { account in
            let key = sortKey(for: account)
            if let first = key.first {
                return String(first).uppercased()
            } else {
                return "#"
            }
        }
    }

    func sortedKeys(from category: Category) -> [String] {
        sortedKeys(fromAccounts: Array(category.accounts))
    }

    func sortedKeys(fromAccounts accounts: [Account]) -> [String] {
        let keys = groupedAccounts(fromAccounts: accounts).keys.sorted()
        switch sortOption {
        case .nameAsc:
            return keys
        case .nameDesc:
            return Array(keys.reversed())
        }
    }

    func addAccount(to category: Category, in context: ModelContext) {
        let trimmedService = newServiceName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedService.isEmpty else { return }

        let hashed = Account.hashedPassword(newPassword)
        let account = Account(serviceName: trimmedService, userName: newUserName, passwordHash: hashed)
        category.accounts.append(account)

        Account.savePassword(newPassword, for: account)

        newServiceName = ""
        newUserName = ""
        newPassword = ""

        try? context.save()
    }

    func toggleSelection(for account: Account) {
        let id = account.id
        if selectedAccountIDs.contains(id) {
            selectedAccountIDs.remove(id)
        } else {
            selectedAccountIDs.insert(id)
        }
    }

    func toggleSelectionMode() {
        withAnimation {
            isSelectionMode.toggle()
            if !isSelectionMode {
                selectedAccountIDs.removeAll()
            }
        }
    }

    func deleteSelectedAccounts(in category: Category, context: ModelContext) {
        guard !selectedAccountIDs.isEmpty else { return }
        let accountsToDelete: [Account]

        if category.name == "全部" || category.name == "收藏" {
            // 在“全部”和“收藏”视图中，需要跨所有分组删除选中的账号
            let descriptor = FetchDescriptor<Account>()
            let allAccounts = (try? context.fetch(descriptor)) ?? []
            accountsToDelete = allAccounts.filter { selectedAccountIDs.contains($0.id) }
        } else {
            // 普通分组：仅在当前分组中删除
            accountsToDelete = category.accounts.filter { selectedAccountIDs.contains($0.id) }
        }

        for account in accountsToDelete {
            Account.deletePassword(for: account)

            if let ownerCategory = account.category,
               let index = ownerCategory.accounts.firstIndex(where: { $0.id == account.id })
            {
                let deletedAccount = ownerCategory.accounts.remove(at: index)
                context.delete(deletedAccount)
            } else if let index = category.accounts.firstIndex(where: { $0.id == account.id }) {
                // 兜底：仍然尝试从传入的 category 中删除
                let deletedAccount = category.accounts.remove(at: index)
                context.delete(deletedAccount)
            }
        }

        try? context.save()
        selectedAccountIDs.removeAll()
    }

    func toggleSelectAllVisible(filteredAccounts: [Account]) {
        let visibleIDs = Set(filteredAccounts.map { $0.id })

        if selectedAccountIDs.isSuperset(of: visibleIDs) && !visibleIDs.isEmpty {
            selectedAccountIDs.subtract(visibleIDs)
        } else {
            selectedAccountIDs.formUnion(visibleIDs)
        }
    }

    func delete(_ indexSet: IndexSet, from accountsInSection: [Account], in category: Category, context: ModelContext) {
        for index in indexSet {
            let accountToDelete = accountsInSection[index]

            Account.deletePassword(for: accountToDelete)
            // 在“全部”和“收藏”视图中，根据账号自己的所属分组删除
            if let ownerCategory = accountToDelete.category,
               let indexInOwner = ownerCategory.accounts.firstIndex(where: { $0.id == accountToDelete.id })
            {
                let deletedAccount = ownerCategory.accounts.remove(at: indexInOwner)
                context.delete(deletedAccount)
            } else if let globalIndex = category.accounts.firstIndex(where: { $0.id == accountToDelete.id }) {
                // 普通分组或兜底逻辑
                let deletedAccount = category.accounts.remove(at: globalIndex)
                context.delete(deletedAccount)
            }
        }
        try? context.save()
    }
}
