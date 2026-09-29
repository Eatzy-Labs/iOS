//
//  MoyaLoggingPlugin.swift
//  Eatzy
//
//  Created by sun on 9/29/26.
//

import Foundation
import Moya

final class MoyaLoggingPlugin: PluginType {
    func willSend(_ request: RequestType, target: TargetType) {
        #if DEBUG
        guard let request = request.request else {
            print("[Network] 유효하지 않은 요청입니다.")
            return
        }

        let method = request.httpMethod ?? "UNKNOWN"
        let url = request.url?.absoluteString ?? "nil"
        var log = "\n➡️ [\(method)] \(url)"

        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            log += "\nHeaders: \(redacted(headers))"
        }
        if let body = request.httpBody, let bodyText = formatted(data: body, redactingBody: true) {
            log += "\nBody: \(bodyText)"
        }

        print(log)
        #endif
    }

    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        #if DEBUG
        switch result {
        case let .success(response):
            let url = response.request?.url?.absoluteString ?? "nil"
            let body = formatted(data: response.data, redactingBody: true) ?? "<empty>"
            print("\n⬅️ [\(response.statusCode)] \(url)\nResponse: \(body)")

        case let .failure(error):
            let url = error.response?.request?.url?.absoluteString ?? "nil"
            print("\n❌ [Network] \(url)\n\(error.localizedDescription)")
        }
        #endif
    }

    private func redacted(_ headers: [String: String]) -> [String: String] {
        headers.reduce(into: [:]) { result, item in
            let isSensitive = ["authorization", "cookie", "set-cookie"]
                .contains(item.key.lowercased())
            result[item.key] = isSensitive ? "<redacted>" : item.value
        }
    }

    private func formatted(data: Data, redactingBody: Bool = false) -> String? {
        guard !data.isEmpty else { return nil }

        if
            var object = try? JSONSerialization.jsonObject(with: data),
            !redactingBody || redactSensitiveValues(in: &object),
            let prettyData = try? JSONSerialization.data(
                withJSONObject: object,
                options: [.prettyPrinted, .sortedKeys]
            )
        {
            return String(data: prettyData, encoding: .utf8)
        }

        return String(data: data, encoding: .utf8)
    }

    private func redactSensitiveValues(in object: inout Any) -> Bool {
        guard var dictionary = object as? [String: Any] else { return true }
        ["password", "verificationToken", "accessToken", "refreshToken"].forEach {
            if dictionary[$0] != nil {
                dictionary[$0] = "<redacted>"
            }
        }
        object = dictionary
        return true
    }
}
