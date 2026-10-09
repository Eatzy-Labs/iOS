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
    var fetchPlaceDetail: @Sendable (
        _ universityCode: String,
        _ placeID: String
    ) async throws -> PlaceDetailResponseDTO
    var fetchCategories: @Sendable () async throws -> PlaceCategoriesResponseDTO
}

extension MapClient: DependencyKey {
    static let liveValue = Self(
        fetchPlaces: { universityCode, category in
            try await MapService().fetchPlaces(
                universityCode: universityCode,
                category: category
            )
        },
        fetchPlaceDetail: { universityCode, placeID in
            try await MapService().fetchPlaceDetail(
                universityCode: universityCode,
                placeID: placeID
            )
        },
        fetchCategories: {
            try await MapService().fetchCategories()
        }
    )

    static let testValue = Self(
        fetchPlaces: { _, _ in
            PlacesResponseDTO(places: [])
        },
        fetchPlaceDetail: { _, _ in
            throw NetworkError.notFound
        },
        fetchCategories: {
            PlaceCategoriesResponseDTO(categories: [])
        }
    )
}

extension DependencyValues {
    var mapClient: MapClient {
        get { self[MapClient.self] }
        set { self[MapClient.self] = newValue }
    }
}
