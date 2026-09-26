//
//  MenuSheetMockData.swift
//  Eatzy
//

enum MenuSheetMockData {
    static func detail(for sectionID: String?) -> MenuSheet {
        MenuSheet(
            title: "[Daily Special]",
            dishes: [
                .init(
                    id: "eel-rice-bowl",
                    name: "Eel Rice Bowl",
                    detail: "장어덮밥",
                    description: "Rich Blood Sausage and sliced Pork Soup and so delicious and yummy",
                    imageNames: Array(repeating: "image-example1", count: 3)
                ),
                .init(
                    id: "squid-radish-soup",
                    name: "Squid and Radish Soup",
                    detail: "오징어무국",
                    description: "Spicy squid soup made with tender squid and radish in a light Korean broth",
                    imageNames: Array(repeating: "image-example2", count: 3)
                ),
                .init(
                    id: "kkanpung-chicken",
                    name: "Kkanpung Chicken Stir-fry",
                    detail: "닭가슴살깐풍볶음",
                    description: "Stir-fried chicken breast coated in a sweet, tangy, and mildly spicy sauce",
                    imageNames: Array(repeating: "image-example3", count: 3)
                )
            ]
        )
    }
}

