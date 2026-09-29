//
//  LogoutClient.swift
//  Eatzy
//

import ComposableArchitecture

struct LogoutClient {
    var logout: @Sendable () async throws -> Void
}

extension LogoutClient: DependencyKey {
    static let liveValue = Self {
        guard let refreshToken = await KeychainTokenStore.shared.refreshToken else {
            try await KeychainTokenStore.shared.delete()
            return
        }

        try await AuthService().logout(
            LogoutRequestDTO(refreshToken: refreshToken)
        )
        try await KeychainTokenStore.shared.delete()
    }

    static let testValue = Self { }
}

extension DependencyValues {
    var logoutClient: LogoutClient {
        get { self[LogoutClient.self] }
        set { self[LogoutClient.self] = newValue }
    }
}
