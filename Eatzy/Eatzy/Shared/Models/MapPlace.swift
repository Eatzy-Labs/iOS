//
//  MapPlace.swift
//  Eatzy
//
//  Created by sun on 10/5/26.
//

import Foundation

struct MapPlace: Equatable, Identifiable {
    struct CategoryOption: Equatable, Identifiable {
        let category: Category
        let title: String

        var id: Category { category }
    }

    struct OperatingHour: Equatable, Identifiable {
        let label: String
        let time: String

        var id: String { label }
    }

    enum Category: String, CaseIterable, Equatable {
        case all
        case cafeteria
        case cafe
        case office
        case store

        nonisolated init?(serverValue: String) {
            guard let category = Self(rawValue: serverValue.lowercased()), category != .all else {
                return nil
            }
            self = category
        }
    }

    let id: String
    let name: String
    let category: Category
    let latitude: Double
    let longitude: Double
    let subtitle: String
    let description: String
    let operatingHours: [OperatingHour]
    let imageNames: [String]
    let imageURLs: [String]
    let hasMenu: Bool
    let cafeteriaCode: String?

    nonisolated init(
        id: String,
        name: String,
        category: Category,
        latitude: Double,
        longitude: Double,
        subtitle: String = "",
        description: String = "",
        operatingHours: [OperatingHour] = [],
        imageNames: [String] = [],
        imageURLs: [String] = [],
        hasMenu: Bool? = nil,
        cafeteriaCode: String? = nil
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.latitude = latitude
        self.longitude = longitude
        self.subtitle = subtitle
        self.description = description
        self.operatingHours = operatingHours
        self.imageNames = imageNames
        self.imageURLs = imageURLs
        self.hasMenu = hasMenu ?? (category == .cafeteria)
        self.cafeteriaCode = cafeteriaCode
    }
}

extension MapPlace.CategoryOption {
    nonisolated init?(_ dto: PlaceCategoryDTO) {
        guard let category = MapPlace.Category(serverValue: dto.code) else {
            return nil
        }
        self.init(category: category, title: dto.nameEn)
    }
}

extension MapPlace {
    nonisolated init?(_ dto: PlaceSummaryDTO) {
        guard let category = Category(serverValue: dto.category) else {
            return nil
        }

        let displayName = dto.nameEn ?? dto.nameKo ?? ""
        let name = [dto.buildingNo, displayName]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        self.init(
            id: String(dto.id),
            name: name,
            category: category,
            latitude: dto.latitude,
            longitude: dto.longitude,
            subtitle: dto.nameKo ?? "",
            description: dto.descriptionEn ?? dto.descriptionKo ?? "",
            hasMenu: dto.hasMenu,
            cafeteriaCode: dto.cafeteriaCode
        )
    }

    nonisolated init?(_ dto: PlaceDetailResponseDTO) {
        guard let category = Category(serverValue: dto.place.category) else {
            return nil
        }

        let displayName = dto.place.nameEn ?? dto.place.nameKo ?? ""
        let name = [dto.place.buildingNo, displayName]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        self.init(
            id: String(dto.place.id),
            name: name,
            category: category,
            latitude: dto.place.latitude,
            longitude: dto.place.longitude,
            subtitle: dto.place.nameKo ?? "",
            description: dto.place.descriptionEn ?? dto.place.descriptionKo ?? "",
            operatingHours: dto.operatingHours.compactMap { operatingHour in
                guard
                    let mealType = operatingHour.mealType,
                    let hours = operatingHour.hours
                else {
                    return nil
                }
                return OperatingHour(
                    label: mealType.lowercased().capitalized,
                    time: hours
                )
            },
            imageURLs: dto.imageUrls,
            hasMenu: dto.place.hasMenu,
            cafeteriaCode: dto.place.cafeteriaCode
        )
    }
}
