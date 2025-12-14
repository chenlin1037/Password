import Foundation
import SwiftData

final class AddAccountViewModel: ObservableObject {
    @Published var serviceName: String = ""
    @Published var userName: String = ""
    @Published var password: String = ""
    @Published var notes: String = ""

    var canSave: Bool {
        !serviceName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !password.isEmpty
    }

    @discardableResult
    func saveAccount(to targetCategory: Category, in context: ModelContext) -> Bool {
        let trimmedService = serviceName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedService.isEmpty, !password.isEmpty else { return false }

        let hashed = Account.hashedPassword(password)
        let newAccount = Account(
            serviceName: trimmedService,
            userName: userName,
            passwordHash: hashed,
            isFavorite: false,
            notes: notes
        )

        Account.savePassword(password, for: newAccount)

        newAccount.category = targetCategory
        targetCategory.accounts.append(newAccount)
        context.insert(newAccount)

        do {
            try context.save()
        } catch {
            print("保存账号失败: \(error.localizedDescription)")
            return false
        }

        serviceName = ""
        userName = ""
        password = ""
        notes = ""

        return true
    }
}
