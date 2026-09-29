//
//  UsersClient.swift
//  Eatzy
//

import ComposableArchitecture

struct UsersClient {
    var fetchMe: @Sendable () async throws -> MeResponseDTO
}

extension UsersClient: DependencyKey {
    static let liveValue = Self {
        try await UsersService().fetchMe()
    }

    static let testValue = Self {
        MeResponseDTO(
            createdAt: "",
            email: "",
            emailVerified: false,
            id: "",
            nationality: "",
            nickname: nil,
            preferredLanguage: "en",
            profileId: nil,
            role: "",
            status: "",
            universityId: 0
        )
    }
}

extension DependencyValues {
    var usersClient: UsersClient {
        get { self[UsersClient.self] }
        set { self[UsersClient.self] = newValue }
    }
}
