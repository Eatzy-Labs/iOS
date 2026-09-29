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
