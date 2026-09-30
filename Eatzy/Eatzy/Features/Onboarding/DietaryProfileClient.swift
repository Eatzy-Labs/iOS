//
//  DietaryProfileClient.swift
//  Eatzy
//
//  Created by sun on 10/1/26.
//


import ComposableArchitecture

struct DietaryProfileClient {
    var replace: @Sendable (DietaryProfileDTO) async throws -> DietaryProfileDTO
}

extension DietaryProfileClient: DependencyKey {
    static let liveValue = Self { request in
        try await UsersService().replaceDietaryProfile(request)
    }

    static let testValue = Self { request in request }
}

extension DependencyValues {
    var dietaryProfileClient: DietaryProfileClient {
        get { self[DietaryProfileClient.self] }
        set { self[DietaryProfileClient.self] = newValue }
    }
}
