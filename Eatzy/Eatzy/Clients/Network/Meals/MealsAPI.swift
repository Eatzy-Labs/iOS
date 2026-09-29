//
//  MealsAPI.swift
//  Eatzy
//

import Alamofire
import Foundation
import Moya

enum MealsAPI: BaseTargetType {
    case meals(
        universityCode: String,
        cafeteriaCode: String,
        date: String,
        language: String
    )

    var baseURL: URL { NetworkConfiguration.baseURL }

    var path: String {
        switch self {
        case let .meals(universityCode, cafeteriaCode, _, _):
            return "/api/v1/universities/\(universityCode)/cafeterias/\(cafeteriaCode)/meals"
        }
    }

    var method: Moya.Method { .get }

    var task: Task {
        switch self {
        case let .meals(_, _, date, language):
            return .requestParameters(
                parameters: ["date": date, "lang": language],
                encoding: URLEncoding.queryString
            )
        }
    }

    var requiresAuthorization: Bool { false }
}
