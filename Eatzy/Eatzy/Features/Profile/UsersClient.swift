//
//  UsersClient.swift
//  Eatzy
//

import ComposableArchitecture

struct UsersClient {
    var fetchMe: @Sendable () async throws -> MeResponseDTO
    var updateProfile: @Sendable (UpdateProfileRequestDTO) async throws -> MeResponseDTO
}

extension UsersClient: DependencyKey {
    static let liveValue = Self(
        fetchMe: {
            try await UsersService().fetchMe()
        },
        updateProfile: { request in
            try await UsersService().updateProfile(request)
        }
    )

    static let testValue = Self(
        fetchMe: {
            testResponse
        },
        updateProfile: { _ in
            testResponse
        }
    )

    nonisolated private static var testResponse: MeResponseDTO {
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
