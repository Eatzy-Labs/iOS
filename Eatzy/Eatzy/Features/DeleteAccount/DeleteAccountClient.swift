//
//  DeleteAccountClient.swift
//  Eatzy
//
//  Created by sun on 10/15/26.
//

import ComposableArchitecture

struct DeleteAccountClient {
    var delete: @Sendable (_ password: String) async throws -> Void
}

extension DeleteAccountClient: DependencyKey {
    static let liveValue = Self { password in
        try await UsersService().deleteAccount(
            DeleteAccountRequestDTO(password: password)
        )
        try await KeychainTokenStore.shared.delete()
    }

    static let testValue = Self { _ in }
}

extension DependencyValues {
    var deleteAccountClient: DeleteAccountClient {
        get { self[DeleteAccountClient.self] }
        set { self[DeleteAccountClient.self] = newValue }
    }
}
