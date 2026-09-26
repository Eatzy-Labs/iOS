//
//  MapPlace.swift
//  Eatzy
//

import Foundation

struct MapPlace: Equatable, Identifiable {
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
    let hasMenu: Bool

    init(
        id: String,
        name: String,
        category: Category,
        latitude: Double,
        longitude: Double,
        subtitle: String = "",
        description: String = "",
        operatingHours: [OperatingHour] = [],
        imageNames: [String] = [],
        hasMenu: Bool? = nil
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
        self.hasMenu = hasMenu ?? (category == .cafeteria)
    }
}
