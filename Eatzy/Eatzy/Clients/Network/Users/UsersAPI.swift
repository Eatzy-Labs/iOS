//
//  UsersAPI.swift
//  Eatzy
//

import Alamofire
import Foundation
import Moya

enum UsersAPI: BaseTargetType {
    case me

    var baseURL: URL { NetworkConfiguration.baseURL }
    var path: String { "/api/v1/users/me" }
    var method: Moya.Method { .get }
    var task: Task { .requestPlain }
    var requiresAuthorization: Bool { true }
}
