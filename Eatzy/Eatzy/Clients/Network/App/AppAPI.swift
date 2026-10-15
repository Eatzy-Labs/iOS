//
//  AppAPI.swift
//  Eatzy
//
//  Created by sun on 10/7/26.
//

import Alamofire
import Foundation
import Moya

enum AppAPI: BaseTargetType {
    case legalDocuments
    case versionRequirement(platform: String)

    var baseURL: URL { NetworkConfiguration.baseURL }
    var path: String {
        switch self {
        case .legalDocuments:
            return "/api/v1/app/legal-documents"
        case .versionRequirement:
            return "/api/v1/app/version-requirement"
        }
    }
    var method: Moya.Method { .get }
    var task: Task {
        switch self {
        case .legalDocuments:
            return .requestPlain
        case let .versionRequirement(platform):
            return .requestParameters(
                parameters: ["platform": platform],
                encoding: URLEncoding.queryString
            )
        }
    }
    var requiresAuthorization: Bool { false }
}
