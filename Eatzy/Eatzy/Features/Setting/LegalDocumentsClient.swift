//
//  LegalDocumentsClient.swift
//  Eatzy
//
//  Created by sun on 10/7/26.
//

import ComposableArchitecture

struct LegalDocumentsClient {
    var fetch: @Sendable () async throws -> LegalDocumentsResponseDTO
}

extension LegalDocumentsClient: DependencyKey {
    static let liveValue = Self {
        try await AppService().fetchLegalDocuments()
    }

    static let testValue = Self {
        LegalDocumentsResponseDTO(privacyUrl: nil, termsUrl: nil)
    }
}

extension DependencyValues {
    var legalDocumentsClient: LegalDocumentsClient {
        get { self[LegalDocumentsClient.self] }
        set { self[LegalDocumentsClient.self] = newValue }
    }
}
