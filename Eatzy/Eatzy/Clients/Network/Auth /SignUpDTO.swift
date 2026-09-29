//
//  SignUpDTO.swift
//  Eatzy
//

import Foundation

struct SignUpRequestDTO: Encodable, Equatable, Sendable {
    let email: String
    let nationality: String
    let password: String
    let preferredLanguage: String
    let termsAgreed: Bool
    let universityCode: String
    let verificationToken: String?
}

struct SignUpResponseDTO: Decodable, Equatable, Sendable {
    let memberId: String?
    let nickname: String?
    let profileId: String?
}
