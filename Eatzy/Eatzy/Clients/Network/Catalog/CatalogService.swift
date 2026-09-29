//
//  CatalogService.swift
//  Eatzy
//

final class CatalogService {
    private let service: BaseService<CatalogAPI>

    init(service: BaseService<CatalogAPI> = BaseService()) {
        self.service = service
    }

    func fetchCatalog(language: String) async throws -> CatalogResponseDTO {
        try await service.request(.catalog(language: language))
    }
}
