//
//  BaseTargetType.swift
//  Eatzy
//
//  Created by sun on 9/29/26.
//

import Foundation
import Moya

protocol BaseTargetType: TargetType {
    var requiresAuthorization: Bool { get }
}

extension BaseTargetType {
    var requiresAuthorization: Bool { true }
    var sampleData: Data { Data() }
    var validationType: ValidationType { .none }

    var headers: [String: String]? {
        [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
    }
}
