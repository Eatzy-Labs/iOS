//
//  CatalogClient.swift
//  Eatzy
//

import ComposableArchitecture

struct CatalogClient {
    var fetch: @Sendable (_ language: String) async throws -> CatalogResponseDTO
    var fetchUniversities: @Sendable () async throws -> UniversitiesResponseDTO
}

extension CatalogClient: DependencyKey {
    static let liveValue = Self(
        fetch: { language in
            try await CatalogService().fetchCatalog(language: language)
        },
        fetchUniversities: {
            try await CatalogService().fetchUniversities()
        }
    )

    static let testValue = Self(
        fetch: { _ in
            CatalogResponseDTO(universities: [])
        },
        fetchUniversities: {
            UniversitiesResponseDTO(universities: [])
        }
    )
}

extension DependencyValues {
    var catalogClient: CatalogClient {
        get { self[CatalogClient.self] }
        set { self[CatalogClient.self] = newValue }
    }
}
