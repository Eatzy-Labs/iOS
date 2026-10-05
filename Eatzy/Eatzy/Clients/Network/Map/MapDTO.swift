//
//  MapDTO.swift
//  Eatzy
//
//  Created by sun on 10/5/26.
//

struct PlacesResponseDTO: Decodable, Equatable, Sendable {
    let places: [PlaceSummaryDTO]
}

struct PlaceDetailResponseDTO: Decodable, Equatable, Sendable {
    let place: PlaceSummaryDTO
    let operatingHours: [PlaceOperatingHourDTO]
    let imageUrls: [String]
}

struct PlaceOperatingHourDTO: Decodable, Equatable, Sendable {
    let mealType: String?
    let hours: String?
}

struct PlaceSummaryDTO: Decodable, Equatable, Sendable {
    let id: Int
    let category: String
    let nameKo: String?
    let nameEn: String?
    let buildingNo: String?
    let latitude: Double
    let longitude: Double
    let descriptionKo: String?
    let descriptionEn: String?
    let cafeteriaCode: String?
    let hasMenu: Bool
}
