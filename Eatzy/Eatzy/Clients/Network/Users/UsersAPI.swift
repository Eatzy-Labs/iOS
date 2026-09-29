//
//  UsersAPI.swift
//  Eatzy
//

import Alamofire
import Foundation
import Moya

enum UsersAPI: BaseTargetType {
    case me
    case updateProfile(UpdateProfileRequestDTO)

    var baseURL: URL { NetworkConfiguration.baseURL }
    var path: String { "/api/v1/users/me" }
    var method: Moya.Method {
        switch self {
        case .me:
            return .get
        case .updateProfile:
            return .patch
        }
    }

    var task: Task {
        switch self {
        case .me:
            return .requestPlain
        case let .updateProfile(request):
            return .requestJSONEncodable(request)
        }
    }
    var requiresAuthorization: Bool { true }
}
