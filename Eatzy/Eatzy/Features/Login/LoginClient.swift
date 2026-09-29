//
//  LoginClient.swift
//  Eatzy
//

import ComposableArchitecture
import UIKit

struct LoginClient {
    var login: @Sendable (_ loginID: String, _ password: String) async throws -> Void
}

extension LoginClient: DependencyKey {
    static let liveValue = Self { loginID, password in
        let deviceName = await UIDevice.current.model
        let request = LoginRequestDTO(
            deviceName: deviceName,
            loginId: loginID,
            password: password,
            platform: "iOS"
        )
        let tokens = try await AuthService().login(request)
        try await KeychainTokenStore.shared.save(tokens)
    }

    static let testValue = Self { _, _ in }
}

extension DependencyValues {
    var loginClient: LoginClient {
        get { self[LoginClient.self] }
        set { self[LoginClient.self] = newValue }
    }
}
