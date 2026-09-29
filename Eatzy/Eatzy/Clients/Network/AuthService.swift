//
//  AuthService.swift
//  Eatzy
//

import Foundation

final class AuthService {
    private let service: BaseService<AuthAPI>

    init(service: BaseService<AuthAPI> = BaseService()) {
        self.service = service
    }

    func signUp(_ request: SignUpRequestDTO) async throws -> SignUpResponseDTO {
        try await service.request(.signUp(request))
    }

    func login(_ request: LoginRequestDTO) async throws -> TokenResponseDTO {
        try await service.request(.login(request))
    }
}
