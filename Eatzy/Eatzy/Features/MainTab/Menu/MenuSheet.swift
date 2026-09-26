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
    }

    let title: String
    let dishes: [Dish]
}

