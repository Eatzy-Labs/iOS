//
//  MapPlace.swift
//  Eatzy
//

import Foundation

struct MapPlace: Equatable, Identifiable {
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
}
