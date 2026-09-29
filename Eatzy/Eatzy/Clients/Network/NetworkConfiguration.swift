//
//  NetworkConfiguration.swift
//  Eatzy
//

import Foundation

enum NetworkConfiguration {
    static var baseURL: URL {
        guard
            let value = Bundle.main.object(forInfoDictionaryKey: "APIBaseURL") as? String,
            let url = URL(string: value)
        else {
            preconditionFailure("API_BASE_URL is missing from Config.xcconfig.")
        }
        return url
    }
}
