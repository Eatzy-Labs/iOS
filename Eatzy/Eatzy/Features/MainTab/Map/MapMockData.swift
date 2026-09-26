//
//  MapMockData.swift
//  Eatzy
//

enum MapMockData {
    static let places: [MapPlace] = [
        .init(
            id: "cafeteria-cheomseong",
            name: "114 Cheomseong Dorm Cafeteria",
            category: .cafeteria,
            latitude: 35.8901,
            longitude: 128.6092,
            subtitle: "첨성관(기숙사) 식당",
            description: "A cafeteria located in the basement of Cheomseong Dormitory, mainly for dormitory residents.",
            operatingHours: [
                .init(label: "Breakfast", time: "07:00 ~ 09:00"),
                .init(label: "Lunch", time: "11:30 ~ 14:00"),
                .init(label: "Dinner", time: "17:30 ~ 19:00")
            ],
            imageNames: ["image-example1", "image-example2"]
        ),
        .init(
            id: "cafeteria-welfare",
            name: "305 Welfare Center Cafeteria",
            category: .cafeteria,
            latitude: 35.8876,
            longitude: 128.6081,
            subtitle: "복지관 식당",
            description: "A cafeteria located in the Welfare Center for students and campus members.",
            operatingHours: [
                .init(label: "Breakfast", time: "07:00 ~ 09:00"),
                .init(label: "Lunch", time: "11:30 ~ 14:00"),
                .init(label: "Dinner", time: "17:30 ~ 19:00")
            ],
            imageNames: ["image-example3"]
        ),
        .init(
            id: "cafe-1",
            name: "Campus Cafe 1",
            category: .cafe,
            latitude: 35.8892,
            longitude: 128.6104
        ),
        .init(
            id: "cafe-2",
            name: "Campus Cafe 2",
            category: .cafe,
            latitude: 35.8884,
            longitude: 128.6077
        ),
        .init(
            id: "office-main",
            name: "Main Office",
            category: .office,
            latitude: 35.8869,
            longitude: 128.6115
        ),
        .init(
            id: "office-student",
            name: "Student Office",
            category: .office,
            latitude: 35.8907,
            longitude: 128.6120
        ),
        .init(
            id: "store-1",
            name: "Campus Store 1",
            category: .store,
            latitude: 35.8879,
            longitude: 128.6100
        ),
        .init(
            id: "store-2",
            name: "Campus Store 2",
            category: .store,
            latitude: 35.8898,
            longitude: 128.6070
        )
    ]
}
