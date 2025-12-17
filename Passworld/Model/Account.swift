//
//  Account.swift
//  Passworld
//
//  Created by luckly on 2025/12/2.
//

import CryptoKit
import Foundation
import Security
import SwiftData

@Model
final class Account {
    var serviceName: String
    var userName: String = ""
    var passwordHash: String = "placeholder"
    var isFavorite: Bool = false
    var notes: String = ""
    var keychainID: String = UUID().uuidString
    var createAt: Date = Date()
    var lastUsedAt: Date?

    @Relationship(inverse: \Category.accounts) var category: Category?
    init(serviceName: String, userName: String, passwordHash: String = "placeholder", isFavorite: Bool = false, notes: String = "", createAt: Date = Date(), keychainID: String = UUID().uuidString, lastUsedAt: Date? = nil) {
        self.serviceName = serviceName
        self.userName = userName
        self.passwordHash = passwordHash
        self.isFavorite = isFavorite
        self.notes = notes
        self.createAt = createAt
        self.keychainID = keychainID
        self.lastUsedAt = lastUsedAt
    }

    // 使用 SHA256 对密码做单向哈希存储
    static func hashedPassword(_ password: String) -> String {
        // 简单固定盐，提高不同应用之间的哈希区分度
        let salted = "Passworld_salt::" + password
        let data = Data(salted.utf8)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    // Keychain 辅助方法：保存/读取/删除明文密码
    private static let keychainService = "Passworld.AccountPassword"

    private static func key(for account: Account) -> String {
        account.keychainID
    }

    static func savePassword(_ password: String, for account: Account) {
        let key = key(for: account)
        guard let data = password.data(using: .utf8) else { return }

        let baseQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key,
        ]

        // 删除旧值，避免重复
        SecItemDelete(baseQuery as CFDictionary)

        var query = baseQuery
        query[kSecValueData as String] = data

        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            #if DEBUG
                print("保存密码到 Keychain 失败: \(status)")
            #endif
        }
    }

    static func loadPassword(for account: Account) -> String? {
        let key = key(for: account)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue as Any,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecSuccess,
           let data = item as? Data,
           let password = String(data: data, encoding: .utf8)
        {
            return password
        }
        return nil
    }

    static func deletePassword(for account: Account) {
        let key = key(for: account)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key,
        ]
        SecItemDelete(query as CFDictionary)
    }
}
