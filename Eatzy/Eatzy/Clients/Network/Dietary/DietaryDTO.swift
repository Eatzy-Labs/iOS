//
//  DietaryDTO.swift
//  Eatzy
//
//  Created by sun on 9/30/26.
//

struct DietaryTaxonomyResponseDTO: Decodable, Equatable, Sendable {
    let diets: [DietDTO]
    let ingredientCategories: [IngredientCategoryDTO]
    let ingredients: [IngredientDTO]
    let religions: [ReligionDTO]
    let spiceScale: SpiceScaleDTO
}

struct DietDTO: Decodable, Equatable, Sendable {
    let code: String
    let nameEn: String
    let nameKo: String
    let presetIngredients: [String]
}

struct IngredientCategoryDTO: Decodable, Equatable, Sendable {
    let code: String
    let nameEn: String
    let nameKo: String
}

struct IngredientDTO: Decodable, Equatable, Sendable {
    let allergen: Bool
    let category: String
    let code: String
    let nameEn: String
    let nameKo: String
    let parent: String?
}

struct ReligionDTO: Decodable, Equatable, Sendable {
    let code: String
    let nameEn: String
    let nameKo: String
    let presets: [ReligionPresetDTO]
}

struct ReligionPresetDTO: Decodable, Equatable, Sendable {
    let code: String
    let diets: [String]
    let ingredients: [String]
    let nameEn: String
    let nameKo: String
}

struct SpiceScaleDTO: Decodable, Equatable, Sendable {
    let max: Int
    let min: Int
}
