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
}
