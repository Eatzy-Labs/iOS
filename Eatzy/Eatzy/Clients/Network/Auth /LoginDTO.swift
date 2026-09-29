//
//  LoginDTO.swift
//  Eatzy
//

import Foundation

struct LoginRequestDTO: Encodable, Equatable, Sendable {
    let deviceName: String
    let loginId: String
    let password: String
    let platform: String
}

struct TokenResponseDTO: Codable, Equatable, Sendable {
    let accessToken: String
    let accessTokenExpiresAt: String
    let refreshToken: String
    let refreshTokenExpiresAt: String
    let tokenType: String
}

struct LogoutRequestDTO: Encodable, Equatable, Sendable {
    let refreshToken: String
}
