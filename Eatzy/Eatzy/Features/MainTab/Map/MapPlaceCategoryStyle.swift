//
//  MapPlaceCategoryStyle.swift
//  Eatzy
//

import SwiftUI

extension MapPlace.Category {
    var title: String {
        switch self {
        case .all: return "All"
        case .cafeteria: return "Cafeteria"
        case .cafe: return "Cafe"
        case .store: return "Store"
        case .office: return "Office"
        }
    }

    var icon: ImageResource {
        switch self {
        case .all: return .icAll
        case .cafeteria: return .icCafeteria
        case .cafe: return .icCafe
        case .store: return .icStore
        case .office: return .icOffice
        }
    }

    var markerImage: UIImage {
        switch self {
        case .all: return UIImage(resource: .typeStore)
        case .cafeteria: return UIImage(resource: .typeCafeteria)
        case .cafe: return UIImage(resource: .typeCafe)
        case .office: return UIImage(resource: .typeOffice)
        case .store: return UIImage(resource: .typeStore)
        }
    }
}

