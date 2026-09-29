//
//  AuthAPI.swift
//  Eatzy
//
//  Created by sun on 9/30/26.
//

import Foundation
import Alamofire
import Moya

enum AuthAPI: BaseTargetType {
    case signUp(SignUpRequestDTO)
    case login(LoginRequestDTO)
    case logout(LogoutRequestDTO)
    case refresh(RefreshRequestDTO)

    var baseURL: URL { NetworkConfiguration.baseURL }

    var path: String {
        switch self {
        case .signUp:
            return "/api/v1/auth/sign-up"
        case .login:
            return "/api/v1/auth/login"
        case .logout:
            return "/api/v1/auth/logout"
        case .refresh:
            return "/api/v1/auth/refresh"
        }
    }

    var method: Moya.Method {
        switch self {
        case .signUp, .login, .logout, .refresh:
            return .post
        }
    }

    var task: Task {
        switch self {
        case let .signUp(request):
            return .requestJSONEncodable(request)
        case let .login(request):
            return .requestJSONEncodable(request)
        case let .logout(request):
            return .requestJSONEncodable(request)
        case let .refresh(request):
            return .requestJSONEncodable(request)
        }
    }

    var requiresAuthorization: Bool { false }
}
