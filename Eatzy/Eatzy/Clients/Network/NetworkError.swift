//
//  NetworkError.swift
//  Eatzy
//
//  Created by sun on 9/29/26.
//


import Foundation

enum NetworkError: Error, Equatable {
    case apiError(code: String, reason: String?)
    case unauthorized
    case notFound
    case internalServerError
    case responseError
    case responseDecodingError
    case networkFail
    case unknownError
}

extension NetworkError {
    var isInvalidRefreshToken: Bool {
        switch self {
        case let .apiError(code, _):
            return code == "AUTH_INVALID_REFRESH_TOKEN"
        case .unauthorized:
            return true
        default:
            return false
        }
    }
}

extension NetworkError: LocalizedError, CustomStringConvertible {
    var errorDescription: String? { description }

    var description: String {
        switch self {
        case let .apiError(code, _):
            switch code {
            case "AUTH_EMAIL_TAKEN":
                return "This email is already in use."
            case "AUTH_INVALID_VERIFICATION_TOKEN":
                return "Email verification is invalid. Please try again."
            case "AUTH_TERMS_REQUIRED":
                return "You must agree to the terms to sign up."
            case "AUTH_INVALID_CREDENTIALS":
                return "The email or password is incorrect."
            case "AUTH_WEAK_PASSWORD":
                return weakPasswordMessage
            case "MEMBER_WRONG_PASSWORD":
                return "The current password is incorrect."
            case "DIETARY_INVALID_CODE":
                return "One or more dietary selections are no longer supported."
            default:
                return "The request could not be completed. (\(code))"
            }
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

    private var weakPasswordMessage: String {
        guard case let .apiError(_, reason) = self else {
            return "Please use a stronger password."
        }
        switch reason {
        case "TOO_SHORT":
            return "Password is too short."
        case "NO_UPPERCASE":
            return "Add at least one uppercase letter."
        case "NO_LOWERCASE":
            return "Add at least one lowercase letter."
        case "NO_DIGIT":
            return "Add at least one number."
        case "NO_SPECIAL":
            return "Add at least one special character."
        default:
            return "Please use a stronger password."
        }
    }
}
