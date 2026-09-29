//
//  DietaryAPI.swift
//  Eatzy
//
//  Created by sun on 9/30/26.
//

import Alamofire
import Foundation
import Moya

enum DietaryAPI: BaseTargetType {
    case taxonomy

    var baseURL: URL { NetworkConfiguration.baseURL }
    var path: String { "/api/v1/dietary/taxonomy" }
    var method: Moya.Method { .get }
    var task: Task { .requestPlain }
    var requiresAuthorization: Bool { false }
}
