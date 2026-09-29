//
//  DietaryClient.swift
//  Eatzy
//
//  Created by sun on 9/30/26.
//

import ComposableArchitecture

struct DietaryClient {
    var fetchTaxonomy: @Sendable () async throws -> DietaryTaxonomyResponseDTO
}

extension DietaryClient: DependencyKey {
    static let liveValue = Self {
        try await DietaryService().fetchTaxonomy()
    }

    static let testValue = Self {
        DietaryTaxonomyResponseDTO(
            diets: [],
            ingredientCategories: [],
            ingredients: [],
            religions: [],
            spiceScale: SpiceScaleDTO(max: 5, min: 1)
        )
    }
}

extension DependencyValues {
    var dietaryClient: DietaryClient {
        get { self[DietaryClient.self] }
        set { self[DietaryClient.self] = newValue }
    }
}
