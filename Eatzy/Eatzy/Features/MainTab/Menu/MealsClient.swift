//
//  MealsClient.swift
//  Eatzy
//

import ComposableArchitecture

struct MealsClient {
    var fetch: @Sendable (
        _ universityCode: String,
        _ cafeteriaCode: String,
        _ date: String,
        _ language: String
    ) async throws -> MealsResponseDTO
}

extension MealsClient: DependencyKey {
    static let liveValue = Self { universityCode, cafeteriaCode, date, language in
        try await MealsService().fetchMeals(
            universityCode: universityCode,
            cafeteriaCode: cafeteriaCode,
            date: date,
            language: language
        )
    }

    static let testValue = Self { _, _, date, _ in
        MealsResponseDTO(
            university: MealsUniversityDTO(
                code: "",
                name: nil,
                nameEn: nil,
                nameKo: nil
            ),
            cafeteria: CatalogCafeteriaDTO(
                code: "",
                buildingNo: nil,
                name: nil,
                nameEn: nil,
                nameKo: nil,
                shortName: nil,
                shortNameEn: nil,
                shortNameKo: nil,
                description: nil,
                descriptionEn: nil,
                descriptionKo: nil,
                operatingHours: []
            ),
            date: date,
            meals: []
        )
    }
}

extension DependencyValues {
    var mealsClient: MealsClient {
        get { self[MealsClient.self] }
        set { self[MealsClient.self] = newValue }
    }
}
