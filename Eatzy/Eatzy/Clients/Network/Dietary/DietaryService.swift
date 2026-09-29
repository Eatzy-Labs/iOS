//
//  DietaryService.swift
//  Eatzy
//
//  Created by sun on 9/30/26.
//

final class DietaryService {
    private let service: BaseService<DietaryAPI>

    init(service: BaseService<DietaryAPI> = BaseService()) {
        self.service = service
    }

    func fetchTaxonomy() async throws -> DietaryTaxonomyResponseDTO {
        try await service.request(.taxonomy)
    }
}
