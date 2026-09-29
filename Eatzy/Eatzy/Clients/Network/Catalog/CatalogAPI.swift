//
//  CatalogAPI.swift
//  Eatzy
//

import Alamofire
import Foundation
import Moya

enum CatalogAPI: BaseTargetType {
    case catalog(language: String)

    var baseURL: URL { NetworkConfiguration.baseURL }
    var path: String { "/api/v1/catalog" }
    var method: Moya.Method { .get }

    var task: Task {
        switch self {
        case let .catalog(language):
            return .requestParameters(
                parameters: ["lang": language],
                encoding: URLEncoding.queryString
            )
        }
    }

    var requiresAuthorization: Bool { false }
}
