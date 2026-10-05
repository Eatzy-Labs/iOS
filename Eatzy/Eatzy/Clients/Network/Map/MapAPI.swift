//
//  MapAPI.swift
//  Eatzy
//
//  Created by sun on 10/5/26.
//

import Alamofire
import Foundation
import Moya

enum MapAPI: BaseTargetType {
    case places(universityCode: String, category: String?)

    var baseURL: URL { NetworkConfiguration.baseURL }

    var path: String {
        switch self {
        case let .places(universityCode, _):
            return "/api/v1/universities/\(universityCode)/places"
        }
    }

    var method: Moya.Method { .get }

    var task: Task {
        switch self {
        case let .places(_, category):
            guard let category else { return .requestPlain }
            return .requestParameters(
                parameters: ["category": category],
                encoding: URLEncoding.queryString
            )
        }
    }

    var requiresAuthorization: Bool { false }
}
