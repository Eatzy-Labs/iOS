//
//  MealsService.swift
//  Eatzy
//

final class MealsService {
    private let service: BaseService<MealsAPI>

    init(service: BaseService<MealsAPI> = BaseService()) {
        self.service = service
    }

    func fetchMeals(
        universityCode: String,
        cafeteriaCode: String,
        date: String,
        language: String
    ) async throws -> MealsResponseDTO {
        try await service.request(
            .meals(
                universityCode: universityCode,
                cafeteriaCode: cafeteriaCode,
                date: date,
                language: language
            )
        )
    }
}
