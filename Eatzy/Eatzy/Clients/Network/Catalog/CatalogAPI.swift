//
//  CatalogAPI.swift
//  Eatzy
//

import Alamofire
import Foundation
import Moya

enum CatalogAPI: BaseTargetType {
    case catalog(language: String)
    case countries(language: String)

    var baseURL: URL { NetworkConfiguration.baseURL }
    var path: String {
        switch self {
        case .catalog:
            return "/api/v1/catalog"
        case .countries:
            return "/api/v1/countries"
        }
    }
    var method: Moya.Method { .get }

    var task: Task {
        switch self {
        case let .catalog(language):
            return .requestParameters(
                parameters: ["lang": language],
                encoding: URLEncoding.queryString
            )
        case let .countries(language):
            return .requestParameters(
                parameters: ["lang": language],
                encoding: URLEncoding.queryString
            )
        }
    }

    var requiresAuthorization: Bool { false }
}
