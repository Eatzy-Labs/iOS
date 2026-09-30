//
//  UsersService.swift
//  Eatzy
//

final class UsersService {
    private let service: BaseService<UsersAPI>

    init(service: BaseService<UsersAPI> = BaseService()) {
        self.service = service
    }

    func fetchMe() async throws -> MeResponseDTO {
        try await service.request(.me)
    }

    func updateProfile(_ request: UpdateProfileRequestDTO) async throws -> MeResponseDTO {
        try await service.request(.updateProfile(request))
    }

    func replaceDietaryProfile(_ request: DietaryProfileDTO) async throws -> DietaryProfileDTO {
        try await service.request(.replaceDietaryProfile(request))
    }
}
