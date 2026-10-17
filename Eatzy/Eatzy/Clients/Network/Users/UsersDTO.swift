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
    let universityCode: String?
    let universityId: Int
}

struct UpdateProfileRequestDTO: Encodable, Equatable, Sendable {
    let nationality: String?
    let nickname: String?
    let preferredLanguage: String?
    let profileId: String?
    let universityCode: String?

    init(
        nationality: String? = nil,
        nickname: String? = nil,
        preferredLanguage: String? = nil,
        profileId: String? = nil,
        universityCode: String? = nil
    ) {
        self.nationality = nationality
        self.nickname = nickname
        self.preferredLanguage = preferredLanguage
        self.profileId = profileId
        self.universityCode = universityCode
    }
}

struct DeleteAccountRequestDTO: Encodable, Equatable, Sendable {
    let password: String
}

struct VerifyPasswordRequestDTO: Encodable, Equatable, Sendable {
    let currentPassword: String
}

struct VerifyPasswordResponseDTO: Decodable, Equatable, Sendable {
    let expiresAt: String
    let passwordChangeToken: String
}

struct ChangePasswordRequestDTO: Encodable, Equatable, Sendable {
    let newPassword: String
    let passwordChangeToken: String
}

struct DietaryProfileDTO: Codable, Equatable, Sendable {
    let avoidedIngredients: [String]
    let diets: [String]
    let maxSpiceLevel: Int?
    let religion: String?
}
