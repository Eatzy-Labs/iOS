//
//  MapDTO.swift
//  Eatzy
//
//  Created by sun on 10/5/26.
//

struct PlacesResponseDTO: Decodable, Equatable, Sendable {
    let places: [PlaceSummaryDTO]
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
