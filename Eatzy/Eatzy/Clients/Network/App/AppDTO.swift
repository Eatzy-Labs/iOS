//
//  AppDTO.swift
//  Eatzy
//
//  Created by sun on 10/7/26.
//

struct LegalDocumentsResponseDTO: Decodable, Equatable, Sendable {
    let privacyUrl: String?
    let termsUrl: String?
}

struct VersionRequirementResponseDTO: Decodable, Equatable, Sendable {
    let latestBuild: Int
    let minSupportedBuild: Int
    let platform: String
}
