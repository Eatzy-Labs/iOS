//
//  AppService.swift
//  Eatzy
//
//  Created by sun on 10/7/26.
//

final class AppService {
    private let service: BaseService<AppAPI>

    init(service: BaseService<AppAPI> = BaseService()) {
        self.service = service
    }

    func fetchLegalDocuments() async throws -> LegalDocumentsResponseDTO {
        try await service.request(.legalDocuments)
    }
}
