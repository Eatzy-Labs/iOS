//
//  SignUpClient.swift
//  Eatzy
//

import ComposableArchitecture

struct SignUpClient {
    var signUp: @Sendable (SignUpRequestDTO) async throws -> SignUpResponseDTO
}

extension SignUpClient: DependencyKey {
    static let liveValue = Self { request in
        try await AuthService().signUp(request)
    }

    static let testValue = Self { _ in
        SignUpResponseDTO(memberId: nil, nickname: nil, profileId: nil)
    }
}

extension DependencyValues {
    var signUpClient: SignUpClient {
        get { self[SignUpClient.self] }
        set { self[SignUpClient.self] = newValue }
    }
}
