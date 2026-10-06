//
//  CatalogDTO.swift
//  Eatzy
//

import Foundation

struct CatalogResponseDTO: Decodable, Equatable, Sendable {
    let universities: [CatalogUniversityDTO]
}

struct UniversitiesResponseDTO: Decodable, Equatable, Sendable {
    let universities: [UniversitySummaryDTO]
}

struct UniversitySummaryDTO: Decodable, Equatable, Sendable {
    let code: String
    let nameEn: String
    let nameKo: String
    let region: String
    let schoolType: String
}

struct CountriesResponseDTO: Decodable, Equatable, Sendable {
    let countries: [CountryDTO]
}

struct CountryDTO: Decodable, Equatable, Sendable {
    let code: String
    let name: String
}

struct CatalogUniversityDTO: Decodable, Equatable, Sendable {
    let code: String
    let name: String?
    let nameEn: String?
    let nameKo: String?
    let cafeterias: [CatalogCafeteriaDTO]
}

struct CatalogCafeteriaDTO: Decodable, Equatable, Hashable, Sendable {
    let code: String
    let buildingNo: String?
    let name: String?
    let nameEn: String?
    let nameKo: String?
    let shortName: String?
    let shortNameEn: String?
    let shortNameKo: String?
    let description: String?
    let descriptionEn: String?
    let descriptionKo: String?
    let operatingHours: [CatalogOperatingHoursDTO]

    var tabTitle: String {
        let displayName = shortName ?? name ?? nameEn ?? nameKo ?? code
        guard let buildingNo, !buildingNo.isEmpty else { return displayName }
        return "\(buildingNo)(\(displayName))"
    }
}

struct CatalogOperatingHoursDTO: Decodable, Equatable, Hashable, Sendable {
    let hours: String?
    let mealType: String?
}
