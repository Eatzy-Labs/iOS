//
//  MenuSheet.swift
//  Eatzy
//

struct MenuSheet: Equatable {
    struct Dish: Equatable, Identifiable {
        let id: String
        let name: String
        let detail: String
        let description: String
        let imageNames: [String]
        let imageURLs: [String]
        let fallbackImageURLs: [String]

        init(
            id: String,
            name: String,
            detail: String,
            description: String,
            imageNames: [String] = [],
            imageURLs: [String] = [],
            fallbackImageURLs: [String] = []
        ) {
            self.id = id
            self.name = name
            self.detail = detail
            self.description = description
            self.imageNames = imageNames
            self.imageURLs = imageURLs
            self.fallbackImageURLs = fallbackImageURLs
        }
    }

    let title: String
    let dishes: [Dish]
}
