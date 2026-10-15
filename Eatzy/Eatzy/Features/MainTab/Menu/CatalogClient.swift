//
//  CatalogClient.swift
//  Eatzy
//

import ComposableArchitecture

struct CatalogClient {
    var fetch: @Sendable (_ language: String) async throws -> CatalogResponseDTO
    var fetchCountries: @Sendable (_ language: String) async throws -> CountriesResponseDTO
}

extension CatalogClient: DependencyKey {
    static let liveValue = Self(
        fetch: { language in
            try await CatalogService().fetchCatalog(language: language)
        },
        fetchCountries: { language in
            try await CatalogService().fetchCountries(language: language)
        }
    )

    static let testValue = Self(
        fetch: { _ in
            CatalogResponseDTO(universities: [])
        },
        fetchCountries: { _ in
            CountriesResponseDTO(countries: [])
        }
    )
}

extension DependencyValues {
    var catalogClient: CatalogClient {
        get { self[CatalogClient.self] }
        set { self[CatalogClient.self] = newValue }
    }
}
