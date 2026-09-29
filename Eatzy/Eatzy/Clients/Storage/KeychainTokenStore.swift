//
//  KeychainTokenStore.swift
//  Eatzy
//

import Foundation
import Security

final class KeychainTokenStore: @unchecked Sendable {
    static let shared = KeychainTokenStore()

    private let service = "com.eatzy.auth"
    private let account = "session"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private init() { }

    var accessToken: String? {
        load()?.accessToken
    }

    func save(_ tokens: TokenResponseDTO) throws {
        let data = try encoder.encode(tokens)
        let query = baseQuery
        let attributes: [String: Any] = [kSecValueData as String: data]

        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if updateStatus == errSecItemNotFound {
            var newItem = query
            newItem[kSecValueData as String] = data
            newItem[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            let addStatus = SecItemAdd(newItem as CFDictionary, nil)
            guard addStatus == errSecSuccess else {
                throw KeychainError.unhandled(addStatus)
            }
        } else if updateStatus != errSecSuccess {
            throw KeychainError.unhandled(updateStatus)
        }
    }

    func delete() throws {
        let status = SecItemDelete(baseQuery as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandled(status)
        }
    }

    private func load() -> TokenResponseDTO? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: CFTypeRef?
        guard
            SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
            let data = result as? Data
        else {
            return nil
        }
        return try? decoder.decode(TokenResponseDTO.self, from: data)
    }

    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}

enum KeychainError: Error {
    case unhandled(OSStatus)
}
