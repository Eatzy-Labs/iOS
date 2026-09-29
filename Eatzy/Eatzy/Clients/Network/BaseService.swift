//
//  BaseService.swift
//  Eatzy
//
//  Created by sun on 9/29/26.
//

import Foundation
import Moya

class BaseService<Target: BaseTargetType> {
    typealias TokenProvider = () -> String?

    private let provider: MoyaProvider<Target>
    private let decoder: JSONDecoder

    init(
        provider: MoyaProvider<Target>? = nil,
        decoder: JSONDecoder = JSONDecoder(),
        tokenProvider: @escaping TokenProvider = { KeychainTokenStore.shared.accessToken },
        additionalPlugins: [PluginType] = []
    ) {
        self.decoder = decoder

        if let provider {
            self.provider = provider
        } else {
            self.provider = MoyaProvider<Target>(
                plugins: [
                    AuthorizationPlugin(tokenProvider: tokenProvider),
                    MoyaLoggingPlugin()
                ] + additionalPlugins
            )
        }
    }

    func request<T: Decodable>(
        _ target: Target,
        as responseType: T.Type = T.self
    ) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(target) { [decoder] result in
                switch result {
                case let .success(response):
                    continuation.resume(
                        with: Self.map(response, decoder: decoder, as: responseType)
                    )

                case let .failure(error):
                    continuation.resume(throwing: Self.map(error))
                }
            }
        }
    }

    func requestWithoutResponse(_ target: Target) async throws {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(target) { [decoder] result in
                switch result {
                case let .success(response):
                    switch response.statusCode {
                    case 200...299:
                        continuation.resume(returning: ())
                    case 400...499:
                        if let errorResponse = try? decoder.decode(
                            APIErrorResponse.self,
                            from: response.data
                        ) {
                            continuation.resume(
                                throwing: NetworkError.apiError(
                                    code: errorResponse.code,
                                    reason: errorResponse.reason
                                )
                            )
                        } else if response.statusCode == 401 || response.statusCode == 403 {
                            continuation.resume(throwing: NetworkError.unauthorized)
                        } else if response.statusCode == 404 {
                            continuation.resume(throwing: NetworkError.notFound)
                        } else {
                            continuation.resume(throwing: NetworkError.responseError)
                        }
                    case 500...599:
                        continuation.resume(throwing: NetworkError.internalServerError)
                    default:
                        continuation.resume(throwing: NetworkError.responseError)
                    }

                case let .failure(error):
                    continuation.resume(throwing: Self.map(error))
                }
            }
        }
    }

    private static func map<T: Decodable>(
        _ response: Response,
        decoder: JSONDecoder,
        as responseType: T.Type
    ) -> Result<T, Error> {
        switch response.statusCode {
        case 200...299:
            do {
                return .success(
                    try decoder.decode(T.self, from: response.data)
                )
            } catch {
                return .failure(NetworkError.responseDecodingError)
            }

        case 400...499:
            let errorResponse = try? decoder.decode(APIErrorResponse.self, from: response.data)
            if let errorResponse {
                return .failure(
                    NetworkError.apiError(
                        code: errorResponse.code,
                        reason: errorResponse.reason
                    )
                )
            }
            if response.statusCode == 401 || response.statusCode == 403 {
                return .failure(NetworkError.unauthorized)
            }
            if response.statusCode == 404 {
                return .failure(NetworkError.notFound)
            }
            return .failure(NetworkError.responseError)
        case 500...599:
            return .failure(NetworkError.internalServerError)
        default:
            return .failure(NetworkError.responseError)
        }
    }

    private static func map(_ error: MoyaError) -> NetworkError {
        switch error {
        case .underlying, .requestMapping, .parameterEncoding:
            return .networkFail
        case .objectMapping, .jsonMapping, .stringMapping:
            return .responseDecodingError
        default:
            return .unknownError
        }
    }
}
