//
//  CatalogClient.swift
//  Eatzy
//

import ComposableArchitecture

struct CatalogClient {
    var fetch: @Sendable (_ language: String) async throws -> CatalogResponseDTO
}

extension CatalogClient: DependencyKey {
    static let liveValue = Self { language in
        try await CatalogService().fetchCatalog(language: language)
    }

    static let testValue = Self { _ in
        CatalogResponseDTO(universities: [])
    }
}

extension DependencyValues {
    var catalogClient: CatalogClient {
        get { self[CatalogClient.self] }
        set { self[CatalogClient.self] = newValue }
    }
}
