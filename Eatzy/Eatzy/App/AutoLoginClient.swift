//
//  AutoLoginClient.swift
//  Eatzy
//
//  Created by sun on 9/30/26.
//

import ComposableArchitecture

struct AutoLoginClient {
    var restoreSession: @Sendable () async -> Bool
}

extension AutoLoginClient: DependencyKey {
    static let liveValue = Self {
        guard let refreshToken = await KeychainTokenStore.shared.refreshToken else {
            return false
        }

        do {
            let tokens = try await AuthService().refresh(
                RefreshRequestDTO(refreshToken: refreshToken)
            )
            try await KeychainTokenStore.shared.save(tokens)
            return true
        } catch let error as NetworkError {
            if error.isInvalidRefreshToken {
                try? await KeychainTokenStore.shared.delete()
            }
            return false
        } catch {
            return false
        }
    }

    static let testValue = Self { false }
}

extension DependencyValues {
    var autoLoginClient: AutoLoginClient {
        get { self[AutoLoginClient.self] }
        set { self[AutoLoginClient.self] = newValue }
    }
}
