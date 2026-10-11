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

    var baseURL: URL { NetworkConfiguration.baseURL }
    var path: String { "/api/v1/app/legal-documents" }
    var method: Moya.Method { .get }
    var task: Task { .requestPlain }
    var requiresAuthorization: Bool { false }
}
