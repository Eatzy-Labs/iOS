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
    case dietaryProfile
    case replaceDietaryProfile(DietaryProfileDTO)

    var baseURL: URL { NetworkConfiguration.baseURL }
    var path: String {
        switch self {
        case .me, .updateProfile:
            return "/api/v1/users/me"
        case .dietaryProfile, .replaceDietaryProfile:
            return "/api/v1/users/me/dietary-profile"
        }
    }
    var method: Moya.Method {
        switch self {
        case .me:
            return .get
        case .updateProfile:
            return .patch
        case .dietaryProfile:
            return .get
        case .replaceDietaryProfile:
            return .put
        }
    }

    var task: Task {
        switch self {
        case .me:
            return .requestPlain
        case let .updateProfile(request):
            return .requestJSONEncodable(request)
        case .dietaryProfile:
            return .requestPlain
        case let .replaceDietaryProfile(request):
            return .requestJSONEncodable(request)
        }
    }
    var requiresAuthorization: Bool { true }
}
