//
//  AuthorizationPlugin.swift
//  Eatzy
//
//  Created by sun on 9/29/26.
//

import Foundation
import Moya

final class AuthorizationPlugin: PluginType {
    typealias TokenProvider = () -> String?

    private let tokenProvider: TokenProvider

    init(tokenProvider: @escaping TokenProvider) {
        self.tokenProvider = tokenProvider
    }

    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        guard
            let target = target as? any BaseTargetType,
            target.requiresAuthorization,
            let token = tokenProvider(),
            !token.isEmpty
        else {
            return request
        }

        var request = request
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
