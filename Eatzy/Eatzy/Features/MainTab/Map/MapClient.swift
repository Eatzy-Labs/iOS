//
//  MapClient.swift
//  Eatzy
//
//  Created by sun on 10/5/26.
//

import ComposableArchitecture

struct MapClient {
    var fetchPlaces: @Sendable (
        _ universityCode: String,
        _ category: String?
    ) async throws -> PlacesResponseDTO
}

extension MapClient: DependencyKey {
    static let liveValue = Self { universityCode, category in
        try await MapService().fetchPlaces(
            universityCode: universityCode,
            category: category
        )
    }

    static let testValue = Self { _, _ in
        PlacesResponseDTO(places: [])
    }
}

extension DependencyValues {
    var mapClient: MapClient {
        get { self[MapClient.self] }
        set { self[MapClient.self] = newValue }
    }
}
