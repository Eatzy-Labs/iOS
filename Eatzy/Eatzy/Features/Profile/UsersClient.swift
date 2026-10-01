//
//  UsersClient.swift
//  Eatzy
//

import ComposableArchitecture

struct UsersClient {
    var fetchMe: @Sendable () async throws -> MeResponseDTO
    var updateProfile: @Sendable (UpdateProfileRequestDTO) async throws -> MeResponseDTO
    var changePassword: @Sendable (ChangePasswordRequestDTO) async throws -> Void
}

extension UsersClient: DependencyKey {
    static let liveValue = Self(
        fetchMe: {
            try await UsersService().fetchMe()
        },
        updateProfile: { request in
            try await UsersService().updateProfile(request)
        },
        changePassword: { request in
            try await UsersService().changePassword(request)
        }
    )

    static let testValue = Self(
        fetchMe: {
            testResponse
        },
        updateProfile: { _ in
            testResponse
        },
        changePassword: { _ in
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
