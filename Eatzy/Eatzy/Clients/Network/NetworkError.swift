//
//  NetworkError.swift
//  Eatzy
//
//  Created by sun on 9/29/26.
//


import Foundation

enum NetworkError: Error, Equatable {
    case apiError(message: String)
    case unauthorized
    case notFound
    case internalServerError
    case responseError
    case responseDecodingError
    case networkFail
    case unknownError
}

extension NetworkError: LocalizedError, CustomStringConvertible {
    var errorDescription: String? { description }

    var description: String {
        switch self {
        case let .apiError(message):
            return message
        case .unauthorized:
            return "인증이 필요합니다."
        case .notFound:
            return "요청한 리소스를 찾을 수 없습니다."
        case .internalServerError:
            return "서버 내부 오류가 발생했습니다."
        case .responseError:
            return "서버로부터 오류 응답을 받았습니다."
        case .responseDecodingError:
            return "응답 데이터를 불러오지 못했습니다."
        case .networkFail:
            return "네트워크 연결에 실패했습니다. 인터넷 상태를 확인해 주세요."
        case .unknownError:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}
