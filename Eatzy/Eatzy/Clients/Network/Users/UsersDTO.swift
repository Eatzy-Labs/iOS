//
//  UsersDTO.swift
//  Eatzy
//

struct MeResponseDTO: Decodable, Equatable, Sendable {
    let createdAt: String
    let email: String
    let emailVerified: Bool
    let id: String
    let nationality: String
    let nickname: String?
    let preferredLanguage: String
    let profileId: String?
    let role: String
    let status: String
    let universityId: Int
}

struct UpdateProfileRequestDTO: Encodable, Equatable, Sendable {
    let nationality: String?
    let nickname: String?
    let preferredLanguage: String?
    let profileId: String?

    init(
        nationality: String? = nil,
        nickname: String? = nil,
        preferredLanguage: String? = nil,
        profileId: String? = nil
    ) {
        self.nationality = nationality
        self.nickname = nickname
        self.preferredLanguage = preferredLanguage
        self.profileId = profileId
    }
}

struct DietaryProfileDTO: Codable, Equatable, Sendable {
    let avoidedIngredients: [String]
    let diets: [String]
    let maxSpiceLevel: Int?
    let religion: String?
}
