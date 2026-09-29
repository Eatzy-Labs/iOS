//
//  MealsDTO.swift
//  Eatzy
//

import Foundation

struct MealsResponseDTO: Decodable, Equatable, Sendable {
    let university: MealsUniversityDTO
    let cafeteria: CatalogCafeteriaDTO
    let date: String
    let meals: [MealBlockDTO]
}

struct MealsUniversityDTO: Decodable, Equatable, Sendable {
    let code: String
    let name: String?
    let nameEn: String?
    let nameKo: String?
}

struct MealBlockDTO: Decodable, Equatable, Sendable {
    let mealType: String
    let options: [MealOptionDTO]
}

struct MealOptionDTO: Decodable, Equatable, Sendable {
    let items: [MealItemDTO]
    let label: String?
    let labelEn: String?
    let labelKo: String?
    let notice: String?
    let noticeEn: String?
    let noticeKo: String?
    let position: Int?
    let price: Int?
}

struct MealItemDTO: Decodable, Equatable, Sendable {
    let dish: MealDishDTO?
    let name: String?
    let nameEn: String?
    let nameKo: String?
    let position: Int?
}

struct MealDishDTO: Decodable, Equatable, Sendable {
    let category: String?
    let dietary: MealDietaryDTO?
    let explanationEn: String?
    let explanationKo: String?
    let id: Int?
    let imageFallbackUrls: [String]?
    let imageUrl: String?
    let imageUrls: [String]?
    let isMain: Bool?
}

struct MealDietaryDTO: Decodable, Equatable, Sendable {
    let ingredients: [String: String]?
    let reviewStatus: String?
    let spiceLevel: Int?
}
