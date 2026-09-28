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
        tokenProvider: @escaping TokenProvider = { nil },
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

    func request<T: ResponseModelType>(
        _ target: Target,
        as responseType: T.Type = T.self
    ) async throws -> BaseResponseBody<T> {
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

    private static func map<T: ResponseModelType>(
        _ response: Response,
        decoder: JSONDecoder,
        as responseType: T.Type
    ) -> Result<BaseResponseBody<T>, Error> {
        switch response.statusCode {
        case 200...299:
            do {
                return .success(
                    try decoder.decode(BaseResponseBody<T>.self, from: response.data)
                )
            } catch {
                return .failure(NetworkError.responseDecodingError)
            }

        case 400, 409, 422:
            let errorResponse = try? decoder.decode(APIErrorResponse.self, from: response.data)
            if let message = errorResponse?.message, !message.isEmpty {
                return .failure(NetworkError.apiError(message: message))
            }
            return .failure(NetworkError.responseError)

        case 401, 403:
            return .failure(NetworkError.unauthorized)
        case 404:
            return .failure(NetworkError.notFound)
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
