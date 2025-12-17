import Foundation
import SwiftData

final class HomeViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var showAddAccountsheet = false
    @Published var selectedCategory: Category? = nil
    @Published var selectedAccountFromSearch: Account? = nil

    // 计算所有分组下账号总数
    func totalAccountCount(categories: [Category]) -> Int {
        categories.flatMap { $0.accounts }.count
    }

    // 初始化默认分组
    func ensureDefaultCategories(in context: ModelContext, existingCategories: [Category]) {
        Category.initializeDefaultCategories(in: context, existingCategories: existingCategories)
    }
}
