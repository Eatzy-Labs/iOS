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
    case placeDetail(universityCode: String, placeID: String)
    case categories

    var baseURL: URL { NetworkConfiguration.baseURL }

    var path: String {
        switch self {
        case let .places(universityCode, _):
            return "/api/v1/universities/\(universityCode)/places"
        case let .placeDetail(universityCode, placeID):
            return "/api/v1/universities/\(universityCode)/places/\(placeID)"
        case .categories:
            return "/api/v1/place-categories"
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
        case .placeDetail:
            return .requestPlain
        case .categories:
            return .requestPlain
        }
    }

    var requiresAuthorization: Bool { false }
}
