//
//  MapService.swift
//  Eatzy
//
//  Created by sun on 10/5/26.
//

final class MapService {
    private let service: BaseService<MapAPI>

    init(service: BaseService<MapAPI> = BaseService()) {
        self.service = service
    }

    func fetchPlaces(
        universityCode: String,
        category: String? = nil
    ) async throws -> PlacesResponseDTO {
        try await service.request(
            .places(universityCode: universityCode, category: category)
        )
    }
}
